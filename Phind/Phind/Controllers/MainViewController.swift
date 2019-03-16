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
  
  /// The start time for the timeline entry
  internal var startTime: Date
  /// The end time for the timeline entry
  internal var endTime: Date?
  /// The label displayed to the user for the timeline entry
  internal var placeLabel: String
  /// Path to image for timeline entry side image
  internal var imagePath: String?
  /// UUID for place described in the timeline entry
  internal var placeUUID: String?
  /// Type of movement for timeline entry; displayed to user as well
  internal var movementType: String
  
  
  // Search UI links.
  var editViewController : EditViewController!
  
  /// Constructor for the TimelineEntry.
  /// - parameter placeUUID: UUID corresponding to Realm object for the place for this TimelineEntry.
  /// - parameter placeLabel: The label for the given place.
  /// - parameter startTime: The date object corresponding to the start of the given entry.
  /// - parameter endTime: The end date for the given timeline entry (optional).
  /// - parameter movementType: The type of movement (from CoreMotion).
  public init(placeUUID: String, placeLabel: String, startTime: Date,
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
  /// UILabel for displaying the date
  @IBOutlet weak var currentDateLabel: UILabel!
  /// UIButton for refreshing
  @IBOutlet weak var refreshButton: UIButton!
  /// UIView for the date header
  @IBOutlet weak var headerView: UIView!
  
  // Search UI links.
  /// SearchViewController object
  var svc : SearchViewController!
  /// UIButton link for search
  var searchFab : UIButton!
  /// Child edit view controller for editing place
  var editViewController: EditViewController!
  
  // Map UI links.
  /// The Apple MapView component
  @IBOutlet weak var mapView: MKMapView!
  
  // Timeline UI links.
  /// The tableView stores the timeline entries.
  @IBOutlet weak var tableView: UITableView!
  /// The tableWrap UIView is the first UIView encapsulating the tableView.
  @IBOutlet weak var tableWrap: UIView!
  /// The shadowWrap encapsulates the tableWrap but contains different stylistic preferences.
  @IBOutlet weak var timelineView: UIView!
  /// Icon for the tabBar (to view additional place or stats information).
  @IBOutlet weak var barIcon: UITabBarItem!
  
  /// Date formatter used to properly format the date in the timeline header
  internal let formatter = DateFormatter()
  /// The PlaceDetailsController is a child UIViewController used to display, hide, and show details on the selected place.
  let placeDetailsController:PlaceDetailsController = UIStoryboard(name: "PlaceDetails", bundle: nil).instantiateViewController(withIdentifier: "PlaceDetails") as! PlaceDetailsController
  
  /// Table content for dynamically reusable cells
  internal var tableItems: [TimelineEntry] = []
  /// Current date used for Header content
  internal var currentDate: Date = Date()
  /// Location entries used to populate timeline.
  internal var locationEntries: [LocationEntry] = []
  
  /// Custom init; could be extended to do additional setup
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
  
  /// Loads style and relevant information for the timeline
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
  
    // Add edit controller for disambiguation
    editViewController = EditViewController()
    self.addChild(editViewController)
    self.view.addSubview(editViewController.view)
    editViewController.view.isHidden = true
    editViewController.view.sizeToFit()
    editViewController.accessedFromEdit = true
  
    // Add popup views.
    self.addChild(placeDetailsController)
    self.view.addSubview(placeDetailsController.view)
    placeDetailsController.view.isHidden = true
  
    // Add popup for search.
    svc = SearchViewController()
    self.addChild(svc)
    self.view.addSubview(svc.view)
    svc.view.isHidden = true
    svc.accessedFromEdit = false
  
    // Load the view.
    self.reloadView()
    self.view.bringSubviewToFront(svc.view)
    self.view.sendSubviewToBack(mapView)
    
  }

  /// Toggle main view controller components' visibility
  public func toggleVisibility(hidden: Bool = false) {
    
    self.headerView.isHidden = hidden
    self.searchFab.isHidden = hidden
    self.placeDetailsController.view.isHidden = true
    self.timelineView.isHidden = hidden
    
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
    
    if timelineEntry.movementType != "STATIONARY" {
      return
    }
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
          latitudinalMeters: Style.MAP_SPAN_LAT,
          longitudinalMeters: Style.MAP_SPAN_LONG
        )
        mapView.setRegion(viewRegion, animated: true)
      
        self.placeDetailsController.setPlaceAndLocation(place: place!, timelineEntry: timelineEntry)
        self.timelineView.isHidden = true
        self.placeDetailsController.setComponentsVisible(visible: true)
      }
    } else {
      // Do not need an else case; unselecting happens by
      // the user pressing the back button.
    }
    
  }
  
}
