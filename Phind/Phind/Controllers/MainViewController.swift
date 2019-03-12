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

/// The TimelineEntry object references a start and end time, a movement time, and a label for the place in the timeline UI.
class TimelineEntry: NSObject {
  
  var startTime: Date
  var endTime: Date?
  var placeLabel: String
  var imagePath: String?
  var placeUUID: String?
  var movementType: String
  
  /// Constructor for the TimelineEntry.
  /// - parameter placeUUID: UUID corresponding to Realm object for the place for this TimelineEntry.
  /// - parameter placeLabel: The label for the given place.
  /// - parameter startTime: The date object corresponding to the start of the given entry.
  /// - parameter endTime: The end date for the given timeline entry (optional).
  /// - parameter movementType: The type of movement (from CoreMotion).
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

/// MainViewController object manages the layout and views for the entire application. In addition to the mapView, date label, and timelineView, it manages a child PlaceDetailsController (which has an additional child UIViewController for editing the place).
class MainViewController: UIViewController, UITableViewDelegate  {
  
  // Header UI links.
  @IBOutlet weak var currentDateLabel: UILabel!
  @IBOutlet weak var refreshButton: UIButton!
  @IBOutlet weak var headerView: UIView!
  
  // Search UI links.
  var svc : SearchViewController!
  var searchFab : UIButton!
  
  // Map UI links.
  @IBOutlet weak var mapView: MKMapView!
  
  // Timeline UI links.
  /// The tableView stores the timeline entries.
  @IBOutlet weak var tableView: UITableView!
  /// The tableWrap UIView is the first UIView encapsulating the tableView.
  @IBOutlet weak var tableWrap: UIView!
  /// The shadowWrap encapsulates the tableWrap but contains different stylistic preferences.
  @IBOutlet weak var shadowWrap: UIView!
  /// Icon for the tabBar (to view additional place or stats information).
  @IBOutlet weak var barIcon: UITabBarItem!
  
  /// Latitudinal span for MapView
  let MAP_SPAN_LAT = 1000.0
  /// Longitudinal span for MapView
  let MAP_SPAN_LONG = 1000.0
  
  /// Date formatter used to properly format the date in the timeline header
  let formatter = DateFormatter()
  /// The PlaceDetailsController is a child UIViewController used to display, hide, and show details on the selected place.
  let placeDetailsController:PlaceDetailsController = UIStoryboard(name: "PlaceDetails", bundle: nil).instantiateViewController(withIdentifier: "PlaceDetails") as! PlaceDetailsController
  
  /// Table content for dynamically reusable cells
  internal var tableItems: [TimelineEntry] = []
  /// Current date used for Header content
  internal var currentDate: Date = Date()
  /// Location entries used to populate timeline.
  internal var locationEntries: [LocationEntry] = []

  convenience init() {
    self.init()
  }
  
  // viewWillAppear and viewDidLoad all follow the cycle delineated
  // here: https://apple.co/2DqFnH6
  override func viewWillAppear(_ animated: Bool) {
    self.reloadView()
  }
  
  /// Update the date used on the label to the provided date parameter.
  /// - parameter date: Date object used to update timeline header.
  internal func updateDate(_ date: Date) {
    
    formatter.dateFormat = "MMM d, yyyy"
    currentDate = date
    currentDateLabel.text = formatter.string(from: currentDate)
    currentDateLabel.center.x = self.view.center.x
    
  }
  
  // loads style and relevant information for the timeline
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
    placeDetailsController.view.isHidden = true
    
    // Add popup for search.
    svc = SearchViewController()
    self.addChild(svc)
    self.view.addSubview(svc.view)
    svc.view.isHidden = true
    
    // Load the view.
    self.reloadView()
    
    self.view.bringSubviewToFront(svc.view)
    self.view.sendSubviewToBack(mapView)
    
  }
  
  /// Reload all internal data and propagate to the timeline view. First updates the location entries for this day, then reloads the map view to show correct pins, and ends by clearing and repopulating the timeline.
  internal func reloadView() {
    
    self.updateLocationEntries()
    self.reloadMapView()
    self.reloadTimelineView()
    
  }
  
  /// Set the internal location entries for the timeline view.
  internal func updateLocationEntries() {
    
    // Get all LocationEntries from today.
    let dayStart = Util.GetLocalizedDayStart(date: currentDate)
    let dayEnd = Util.GetLocalizedDayEnd(date: currentDate)
    self.locationEntries = ModelManager.shared.getLocationEntries(start: dayStart, end: dayEnd)
    Logger.shared.debug("LocationEntries (all): \(locationEntries)")
    
  }
  
  /// Display the place popup view and send the right information to the popup view controller.
  /// - parameter selected: Whether the user has selected a given table entry.
  /// - parameter timelineEntry: The timelineEntry object related to the table entry selected by the user.
  func displayPlacePopup(selected: Bool, timelineEntry: TimelineEntry) {
    let placeUUID = timelineEntry.placeUUID
    if (selected) {
      let uuid = placeUUID!
      let place = ModelManager.shared.getPlaceWithUUID(uuid: uuid)
      if place != nil {
        // Set the place for the place details view and load that view
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
        
        self.placeDetailsController.setPlaceAndLocation(place: place!, timelineEntry: timelineEntry)
        self.placeDetailsController.view.isHidden = false
        self.shadowWrap.isHidden = true
      }
    } else {
      // Do not need an else case; unselecting happens by
      // the user pressing the back button.
    }
  }
  
}
