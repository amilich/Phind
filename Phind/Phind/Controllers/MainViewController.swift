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

class MainViewController: UIViewController, UITableViewDelegate  {
  
  // Header UI links.
  @IBOutlet weak var currentDateLabel: UILabel!
  @IBOutlet weak var refreshButton: UIButton!
  @IBOutlet weak var headerView: UIView!
  
  // Map UI links.
  @IBOutlet weak var mapView: MKMapView!
  
  // Timeline UI links.
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tableWrap: UIView!
  @IBOutlet weak var shadowWrap: UIView!
  
  // Misc
  @IBOutlet weak var barIcon: UITabBarItem!
  
  // Constants.
  let MAP_SPAN_LAT = 1000.0
  let MAP_SPAN_LONG = 1000.0
  let ROUTE_WIDTH: CGFloat = 4.0
  let ROUTE_COLOR: UIColor = Style.SECONDARY_COLOR
  
  // TODO: Should this be moved into a function?
  let formatter = DateFormatter()
  let placeDetailsController = PlaceDetailsController()
  
  // Table content for dynamically reusable cells
  internal var tableItems: [TimelineEntry] = []
  internal var currentDate: Date = Date()
  internal var locationEntries: [LocationEntry] = []

  // viewWillAppear and viewDidLoad all follow the cycle delineated
  // here: https://apple.co/2DqFnH6
  override func viewWillAppear(_ animated: Bool) {
    self.reloadView()
  }
  
  internal func updateDate(_ date: Date) {
    
    formatter.dateFormat = "MMM d, yyyy"
    currentDate = date
    currentDateLabel.text = formatter.string(from: currentDate)
    currentDateLabel.center.x = self.view.center.x
    
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    self.updateDate(Date())
    
    // Setup all the UI.
    self.setupHeaderView()
    self.setupTimelineView()
    self.tabBarController?.tabBar.isHidden = true
    self.mapView.delegate = self

    // Add popup views.
    self.addChild(placeDetailsController)
    self.view.addSubview(placeDetailsController.view)
    placeDetailsController.didMove(toParent: self)
    placeDetailsController.view.frame = self.tableView.frame
    
    // Load the view.
    self.reloadView()
    
  }
  
  internal func reloadView() {
    
    self.updateLocationEntries()
    self.reloadMapView()
    self.reloadTimelineView()
    
  }
  
  internal func updateLocationEntries() {
    
    // Get all LocationEntries from today.
    let dayStart = Util.GetLocalizedDayStart(date: currentDate)
    let dayEnd = Util.GetLocalizedDayEnd(date: currentDate)
    self.locationEntries = ModelManager.shared.getLocationEntries(start: dayStart, end: dayEnd)
    Logger.shared.debug("LocationEntries (all): \(locationEntries)")
    
  }
  
  // Display the place popup view and send the right information
  // to the popup view controller.
  func displayPlacePopup(selected: Bool, placeUUID: String?) {
    
    print("Set selected \(selected)")
    if (selected) {
      let uuid = placeUUID!
      let place = ModelManager.shared.getPlaceWithUUID(uuid: uuid)
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
        
        self.placeDetailsController.setPlace(place: place!)
        self.placeDetailsController.view.isHidden = false
        self.shadowWrap.isHidden = true
      }
    } else {
      // Do not need an else case; unselecting happens by
      // the user pressing the back button.
    }
    
  }
}
