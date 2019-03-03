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
import CardParts

class TimelineEntry: NSObject {
  var startTime: Date
  var endTime: Date?
  var placeLabel: String
  var imagePath: String?
  var placeUUID: String?
  
  init(placeUUID: String, placeLabel: String, startTime: Date, endTime: Date?) {
    self.placeUUID = placeUUID
    self.placeLabel = placeLabel
    self.startTime = startTime
    self.endTime = endTime
    
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
  let ROUTE_COLOR: UIColor = UIColor(
    red: 232.0 / 255.0,
    green: 84.0 / 255.0,
    blue: 142.0 / 255.0,
    alpha: 0.8
  )
  
  // Setup all the links to the UI.
  @IBOutlet weak var currentDateLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var refreshButton: UIButton!
  @IBOutlet weak var tableWrap: UIView!
  
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
    // TODO(kevin): Update this to display date as Feb 9, 2019,
    //              instead of Feb 09, 2019.
    updateDate(Date())
    
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
        
    // Register the table cell as custom type
    setupTableView();
    
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    
    // Add the route to the map and sync the timeline to today
    reloadMapView();
    
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
    let locationEntries = ModelManager.shared.getLocationEntries(from: currentDate, number_of_days: 1)
    
    Logger.shared.debug("LocationEntries (all): \(locationEntries)")
    
    self.tableItems.removeAll()
    
    // Iterate through each LocationEntry to draw pins and routes, as well
    // as generate cards for the timeline.
    var lastCoord: CLLocationCoordinate2D?
    var lastPlace = TimelineEntry(
      placeUUID: "<NONE>",
      placeLabel: "",
      startTime: Date(),
      endTime: Date()
    ) // TODO(Andrew) make nil?

    // Set date format for timeline labels
    for locationEntry in locationEntries {
      if locationEntry.movement_type == MovementType.STATIONARY.rawValue {
        drawPin(&lastCoord, locationEntry)
        addTimelineEntry(locationEntry)
      } else {
        // TODO decide if we want lines
        drawRoute(&lastCoord, locationEntry)
      }
    }
    tableView.reloadData()
    
    // Recenter and resize map.
    if self.mapView.annotations.count > 0 {
      self.mapView!.fitAll()
    }
  }
  
  // Register cell element and data source with table view
  func setupTableView() {
    
    // Style the table view.
    tableWrap.layer.shadowOpacity = 0.16
    tableWrap.layer.shadowColor = UIColor.black.cgColor
    tableWrap.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    tableWrap.layer.shadowRadius = 4.0
    
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
        endTime: locationEntry.end as Date?
      )
      self.tableItems.append(timelineEntry)
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
    let locationDescription = self.tableItems[indexPath.item]
    let cellLabel = tableCell.cellLabel
    cellLabel!.text = locationDescription.placeLabel

    formatter.dateFormat = "h:mm a"

    let timeLabel = tableCell.timeLabel
    let startTime = formatter.string(from: locationDescription.startTime as Date)
    let endTime = (locationDescription.endTime != nil) ? formatter.string(from: locationDescription.endTime! as Date) : ""
    let timeString = (locationDescription.endTime != nil) ? String(format: "from %@ to %@", startTime, endTime) : String(format: "from %@", startTime)
    timeLabel!.text = timeString
    
    // TODO(Andrew) set the UIImage if index is zero or last
    return tableCell
    
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
