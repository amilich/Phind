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

class TimelinePin: NSObject, MKAnnotation {
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

class TimelineController: UIViewController, MKMapViewDelegate {
  
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
  
  // TODO: Should this be moved into a function?
  let realm = try! Realm()
  let formatter = DateFormatter()
  
  // Table content for dynamically reusable cells
  var tableItems: [String] = []

  // viewWillAppear and viewDidLoad all follow the cycle delineated
  // here: https://apple.co/2DqFnH6
  override func viewWillAppear(_ animated: Bool) {
    mapView.delegate = self
    
    // Setup all the UI elements to the proper dynamic values.
    
    // Update current date label at the top of the screen.
    // TODO(kevin): Update this to display date as Feb 9, 2019,
    //              instead of Feb 09, 2019.
    let date = Date()
    formatter.dateFormat = "MMM dd, yyyy"
    currentDateLabel.text = formatter.string(from: date)
    currentDateLabel.center.x = self.view.center.x
    
    // Reload map plot and timeline
    reloadMapView();
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Register the table cell as custom type
    setupTableView();
    
    // Get all LocationEntries from today.
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    
    // Add the route to the map and sync the timeline to today
    reloadMapView();
  }
  
  // Add locations from today to map and timeline
  func reloadMapView() {
    // Get all LocationEntries from today.
    let locationEntries = ModelManager.shared.getLocationEntries()
    self.tableItems.removeAll()
    // Iterate through each LocationEntry to draw pins and routes, as well
    // as generate cards for the timeline.
    var lastCoord: CLLocationCoordinate2D?
    for locationEntry in locationEntries {
      if locationEntry.movement_type == MovementType.STATIONARY.rawValue {
        drawPin(&lastCoord, locationEntry)
      } else {
        drawRoute(&lastCoord, locationEntry)
      }
      self.tableItems.append(String(format:"%f, %f", locationEntry.latitude, locationEntry.longitude));
    }
    
    // Center map around lastCoord.
    if lastCoord != nil {
      // TODO: If lastCoord is nil, then use current coordinates.
      let viewRegion = MKCoordinateRegion(center: lastCoord!, latitudinalMeters: MAP_SPAN_LAT, longitudinalMeters: MAP_SPAN_LONG)
      mapView.setRegion(viewRegion, animated: true)
    }
  }
  
  // Register cell element and data source with table view
  func setupTableView() {
    self.tableView.register(TimelineUITableViewCell.self, forCellReuseIdentifier: "TimelineUITableViewCell")
    self.tableView.separatorStyle = .none
    self.tableView.dataSource = self
  }
  
  func drawPin(_ lastCoord: inout CLLocationCoordinate2D?, _ locationEntry: LocationEntry) {
    
    // Add a pin for each stationary location on the map.
    formatter.dateFormat = "HH:mm:ss"
    var subtitle = formatter.string(from: locationEntry.start as Date)
    if locationEntry.end != nil {
      subtitle += " to " + formatter.string(from: locationEntry.end! as Date)
    } else {
      subtitle += " to now"
    }
    print(locationEntry.start)
    
    // If lastCoord exists before pin is drawn, draw a line from the
    // lastCoord to this point.
    let currCoord = CLLocationCoordinate2D(
      latitude: locationEntry.latitude,
      longitude: locationEntry.longitude
    )
    if (lastCoord != nil) {
      let routeCoords: [CLLocationCoordinate2D] = [lastCoord!, currCoord]
      let routeLine = MKPolyline(coordinates: routeCoords, count: routeCoords.count)
      mapView.addOverlay(routeLine)
    }
    
    // Update lastCoord and draw pin.
    lastCoord = currCoord
    let annotation: TimelinePin = TimelinePin(
      coordinate: lastCoord!,
      subtitle: subtitle
    )
    mapView.addAnnotation(annotation)
    print("Stationary annotation added.")
    
  }
  
  func drawRoute(_ lastCoord: inout CLLocationCoordinate2D?, _ locationEntry: LocationEntry) {
    
    // Draw a route for commuting component.
    var routeCoords: [CLLocationCoordinate2D] = []
    
    // Insert lastCoord as first coordinate in route.
    if (lastCoord != nil) {
      routeCoords.append(lastCoord!)
    }
    
    for rawCoord in locationEntry.raw_coordinates {
      let coord = CLLocationCoordinate2DMake(rawCoord.latitude, rawCoord.longitude)
      routeCoords.append(coord)
    }
    lastCoord = routeCoords.last
    let routeLine = MKPolyline(coordinates: routeCoords, count: routeCoords.count)
    mapView.addOverlay(routeLine)
    print("Route added.")
    
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    //Return an `MKPolylineRenderer` for the `MKPolyline` in the `MKMapViewDelegate`s method
    if let polyline = overlay as? MKPolyline {
      let mapLineRenderer = MKPolylineRenderer(polyline: polyline)
      mapLineRenderer.strokeColor = ROUTE_COLOR
      mapLineRenderer.lineWidth = ROUTE_WIDTH
      return mapLineRenderer
    }
    fatalError("Something wrong...")
    //return MKOverlayRenderer()
  }
}

extension TimelineController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let tableCell = tableView.dequeueReusableCell(withIdentifier: "TimelineUITableViewCell", for: indexPath) as! TimelineUITableViewCell
    let item = self.tableItems[indexPath.item]
    tableCell.cellLabel?.text = item
    return tableCell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.tableItems.count
  }
  
}
