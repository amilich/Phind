//
//  TimelineController.swift
//  Phind
//
//  Created by Andrew B. Milich on 1/26/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import RealmSwift
import JustLog


class TimelineEntry: NSObject {
  var startTime: Date
  var endTime: Date?
  var placeLabel: String
  var imagePath: String?
  var placeUUID: String?
  var movementType: String
  
  init(placeUUID: String, placeLabel: String, startTime: Date,
       endTime: Date?, movementType: String) {
    
    self.placeUUID = placeUUID
    self.placeLabel = placeLabel
    self.startTime = startTime
    self.endTime = endTime
    self.movementType = movementType
    
    super.init()
    
  }
}

class MapPin: NSObject, MKAnnotation {
  dynamic var coordinate: CLLocationCoordinate2D
  dynamic var title: String?
  dynamic var subtitle: String?
  
  init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
    self.coordinate = coordinate
    self.title = title
    self.subtitle = subtitle
    
    super.init()
  }
}

class TimelineController: UIViewController, MKMapViewDelegate, UITableViewDelegate  {
  
  // Constants.
  let MAP_SPAN_LAT = 1000.0
  let MAP_SPAN_LONG = 1000.0
  let ROUTE_WIDTH: CGFloat = 4.0
  let ROUTE_COLOR: UIColor = Util.SECONDARY_COLOR
  
  // Setup all the links to the UI.
  @IBOutlet weak var currentDateLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var refreshButton: UIButton!
  @IBOutlet weak var tableWrap: UIView!
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var shadowWrap: UIView!
  @IBOutlet weak var barIcon: UITabBarItem!
  
  // TODO: Should this be moved into a function?
  let realm = try! Realm()
  let formatter = DateFormatter()
  let placePopupViewController = PlacePopupViewController()
  
  // Table content for dynamically reusable cells
  private var tableItems: [TimelineEntry] = []
  private var currentDate: Date = Date()

  // viewWillAppear and viewDidLoad all follow the cycle delineated
  // here: https://apple.co/2DqFnH6
  override func viewWillAppear(_ animated: Bool) {
    
    mapView.delegate = self
    
    // Setup all the UI elements to the proper dynamic values.
    
    // Update current date label at the top of the screen.
    reloadMapView()
    
  }
  
  @IBAction func refreshButton(_ sender: Any) {
    reloadMapView()
  }
  
  @IBAction func previousDayButton(_ sender: Any) {
    updateDate(Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!)
  }
  
  @IBAction func nextDayButton(_ sender: Any) {
    updateDate(Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!)
  }
  
  private func updateDate(_ date: Date) {
    
    formatter.dateFormat = "MMM d, yyyy"
    currentDate = date
    currentDateLabel.text = formatter.string(from: currentDate)
    currentDateLabel.center.x = self.view.center.x
    
    reloadMapView()
    
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    updateDate(Date())
  
    setupHeaderView()
    // Register the table cell as custom type
    setupTableView();
    
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"

    // Add popup views.
    self.addChild(placePopupViewController)
    self.view.addSubview(placePopupViewController.view)
    placePopupViewController.didMove(toParent: self)
    placePopupViewController.view.frame = self.tableView.frame
    
  }
  
  // Add locations from today to map and timeline
  func reloadMapView() {
    
    // Reset mapkit view.
    mapView.removeAnnotations(mapView.annotations)
    mapView.removeOverlays(mapView.overlays)
    
    // Get all LocationEntries from today.
    let dayStart = Util.GetLocalizedDayStart(date: currentDate)
    let dayEnd = Util.GetLocalizedDayEnd(date: currentDate)
    
    let locationEntries = ModelManager.shared.getLocationEntries(start: dayStart, end: dayEnd)
    
    Logger.shared.debug("LocationEntries (all): \(locationEntries)")
    
    self.tableItems.removeAll()
    
    // Iterate through each LocationEntry to draw pins and routes, as well
    // as generate cards for the timeline.
    var lastCoord: CLLocationCoordinate2D?

    // Iterate through location entries and draw them on the map.
    for locationEntry in locationEntries {
      addTimelineEntry(locationEntry)
      if locationEntry.movement_type == MovementType.STATIONARY.rawValue {
        drawPin(&lastCoord, locationEntry)
      } else {
        // TODO: Add location entries to timeline even if they are not stationary.
        drawRoute(&lastCoord, locationEntry)
      }
    }
    tableView.reloadData()
    
    // Recenter and resize map.
    if self.mapView.annotations.count > 0 {
      self.mapView!.fitAll()
    }
    
  }
  
  func setupHeaderView() {
    
    // Setup header view.
    headerView.layer.shadowOpacity = 0.16
    headerView.layer.shadowColor = UIColor.black.cgColor
    headerView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    headerView.layer.shadowRadius = 4.0
    headerView.backgroundColor = Util.PRIMARY_COLOR
    
  }
  
  // Register cell element and data source with table view
  func setupTableView() {
    
    // Setup shadow.
    shadowWrap.layer.shadowOpacity = 0.16
    shadowWrap.layer.shadowColor = UIColor.black.cgColor
    shadowWrap.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    shadowWrap.layer.shadowRadius = 4.0
    shadowWrap.layer.cornerRadius = 32.0
    shadowWrap.frame.size.width = UIScreen.main.bounds.width
    
    // Timeline card setup.
    tableWrap.layer.cornerRadius = 32.0
    tableWrap.clipsToBounds = true
    tableWrap.frame.size.width = shadowWrap.frame.size.width
    
    tableView.frame.size.width = shadowWrap.frame.size.width
    self.tableView.contentInset = UIEdgeInsets(top: 24, left: 0,bottom: 0, right: 0)
    
    self.tableView.register(TimelineUITableViewCell.self, forCellReuseIdentifier: "TimelineCell")
    self.tableView.separatorStyle = .none
    self.tableView.dataSource = self
    self.tableView.delegate = self
    
  }
  
  func drawPin(_ lastCoord: inout CLLocationCoordinate2D?, _ locationEntry: LocationEntry) {
    
    // Add a pin for each stationary location on the map.
    formatter.dateFormat = "h:mm a"
    // TODO: Remove the PinI.
    var subtitle = formatter.string(from: locationEntry.start as Date)
    if locationEntry.end != nil {
      subtitle += " to " + formatter.string(from: locationEntry.end! as Date)
    } else {
      subtitle += " to now"
    }
    
    let currCoord = CLLocationCoordinate2D(
      latitude: locationEntry.latitude,
      longitude: locationEntry.longitude
    )
    
    // If lastCoord exists before pin is drawn, draw a line from the
    // lastCoord to this point.
    if lastCoord != nil {
      let routeCoords: [CLLocationCoordinate2D] = [lastCoord!, currCoord]
      let routeLine = MKPolyline(coordinates: routeCoords, count: routeCoords.count)
      mapView.addOverlay(routeLine)
    }
    
    // Update lastCoord and draw pin.
    lastCoord = currCoord
    let annotation: MapPin = MapPin(
      coordinate: currCoord,
      subtitle: subtitle
    )
    mapView.addAnnotation(annotation)
    
  }
  
  func drawRoute(_ lastCoord: inout CLLocationCoordinate2D?, _ locationEntry: LocationEntry) {
    
    // Draw a route for commuting component.
    var routeCoords: [CLLocationCoordinate2D] = []
    
    // Insert lastCoord as first coordinate in route.
    if (lastCoord != nil) {
      routeCoords.append(lastCoord!)
    }
    
    // Ensure that coordinatse are in proper order, by timestamp.
    var raw_coordinates = locationEntry.raw_coordinates
    raw_coordinates.sort(
      by: { $0.timestamp.compare($1.timestamp as Date) == ComparisonResult.orderedAscending }
    )
    
    for rawCoord in raw_coordinates {
      let coord = CLLocationCoordinate2DMake(rawCoord.latitude, rawCoord.longitude)
      routeCoords.append(coord)
    }
    lastCoord = routeCoords.last

    let routeLine = MKPolyline(coordinates: routeCoords, count: routeCoords.count)
    mapView.addOverlay(routeLine)
    print("Route added.")
    
  }
  
  func addTimelineEntry(_ locationEntry: LocationEntry) {
    
    let place = ModelManager.shared.getPlace(locationEntry: locationEntry)
    if place != nil {
      let timelineEntry = TimelineEntry(
        placeUUID: place!.uuid,
        placeLabel: place!.name,
        startTime: locationEntry.start as Date,
        endTime: locationEntry.end as Date?,
        movementType: locationEntry.movement_type
      )
      self.tableItems.insert(timelineEntry, at: 0)
    }

    // TODO: What do we do if place ID is nil?
    
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    
    // Return an `MKPolylineRenderer` for the `MKPolyline` in the `MKMapViewDelegate`s method
    if let polyline = overlay as? MKPolyline {
      let mapLineRenderer = MKPolylineRenderer(polyline: polyline)
      mapLineRenderer.strokeColor = ROUTE_COLOR
      mapLineRenderer.lineWidth = ROUTE_WIDTH
      return mapLineRenderer
    }
    fatalError("Something wrong...")

  }
  
  // Display the place popup view and send the right information
  // to the popup view controller.
  func displayPlacePopup(selected: Bool, placeUUID: String?) {
    
    print("Set selected \(selected)")
    if (selected) {
      let uuid = placeUUID!
      let place = ModelManager.shared.getPlaceWithUUID(uuid: uuid)
      print("Address")
      print(place!.address)
      if place != nil {
        // TODO(Andrew) why does place lat/lon return -180.0 for both
        // Temporarily looking for a location entry with given place UUID
        self.reloadMapView()
        let centCoord = CLLocationCoordinate2D(
          latitude: place!.latitude,
          longitude: place!.longitude
        )
        let viewRegion = MKCoordinateRegion(
          center: centCoord,
          latitudinalMeters: MAP_SPAN_LAT,
          longitudinalMeters: MAP_SPAN_LONG
        )
        mapView.setRegion(viewRegion, animated: true)
        
        self.placePopupViewController.setPlace(place: place!)
        self.placePopupViewController.view.isHidden = false
      }
    } else {
      // Do not need an else case; unselecting happens by
      // the user pressing the back button.
    }
    
  }
}

extension TimelineController: UITableViewDataSource {
  
  // Computes cell content based on the shared array of tableItems
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let tableCell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell", for: indexPath) as! TimelineUITableViewCell
    
    // Get the location description string set by the TimelineController
    let locationEntry = self.tableItems[indexPath.item]
    let startTime = locationEntry.startTime as Date
    let endTime = locationEntry.endTime as Date?
    
    // Table cell fields.
    let cellLabel = tableCell.cellLabel
    if (locationEntry.movementType == "STATIONARY") {
      cellLabel!.text = locationEntry.placeLabel
    } else {
      cellLabel!.text = locationEntry.movementType.capitalized
    }
      
    // Update time label.
    let timeLabel = tableCell.timeLabel
    if (locationEntry.movementType == "STATIONARY") {
      formatter.dateFormat = "h:mm a"
      let startTimeString = formatter.string(from: startTime)
      let endTimeString = (endTime != nil) ? formatter.string(from: endTime!) : "now"
      let timeString = String(format: "from %@ to %@", startTimeString, endTimeString)
      timeLabel!.text = timeString
    } else {
      timeLabel!.text = ""
    }
    
    // Calculate and assign duration of stay at location.
    let duration : Int = abs (Int( startTime.timeIntervalSince(endTime ?? Date()) ))
    let hours : Int = Int (duration / 3600)
    let min : Int = Int( (duration % 3600) / 60 )
    tableCell.durationLabel!.text = String(hours) + "h " + String(min) + "m"
    
    // Assign proper UIImage.
    let cellImage = tableCell.cellImage!
    if (locationEntry.movementType != "STATIONARY") {
      cellImage.image = UIImage(named: "timeline_line.png")
    } else if (indexPath.item == 0) {
      cellImage.image = UIImage(named: "timeline_joint_first.png")
    } else if indexPath.item == self.tableItems.count - 1 {
      cellImage.image = UIImage(named: "timeline_joint_last.png")
    } else {
      cellImage.image = UIImage(named: "timeline_joint.png")
    }
    
    // TODO(Andrew) set the UIImage if index is zero or last
    return tableCell
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    // TODO: Make this a constant.
    return 64.0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.tableItems.count
  }
  
  // Called when you tap a row in the table; displays the place popup
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let timelineIdx = indexPath[1]
    displayPlacePopup(selected: true, placeUUID: self.tableItems[timelineIdx].placeUUID)
  }
  
}
