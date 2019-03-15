//
//  MainView_PlaceDetails.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//
import UIKit
import RealmSwift
import GoogleMaps
import GooglePlaces
import JustLog

/// The PlaceDetailsController class is the UIViewController responsible for managing all UI components on the place details page.
class PlaceDetailsController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  // Data storage elements
  /// The place object represents the current Realm place used to display details
  public var place = Place()
  /// The internal timelineEntry corresponds to the set of timeline entries related to the given place. A place may correspond to multiple timeline entries (such as an individual's home or workplace).
  public var timelineEntry = TimelineEntry(placeUUID: "", placeLabel: "", startTime:Date(), endTime:Date(), movementType: "")
  /// This data structure holds the UIImages for the photo collection in the place details page.
  var placeImages: [UIImage] = []
  
  // UI components
  /// Wrap for details page to add shadow
  @IBOutlet var shadowWrap: UIView!
  /// Surrounding UIView wrap for the UICollectionViewFlowLayout
  @IBOutlet var flowWrap: UIView!
  /// Place label
  @IBOutlet var label: UILabel!
  /// Address label
  @IBOutlet var addressLabel: UILabel!
  /// Back button to return to timeline view
  @IBOutlet var backButton: UIButton!
  /// Outputs place statistics
  @IBOutlet var statisticsLabel: UILabel!
  /// Edit button to change the saved place
  @IBOutlet var editButton: UIButton!
  /// Collection view for the set of photos
  @IBOutlet var collectionView: UICollectionView!
  /// Flow layout for photos
  @IBOutlet var flowLayout: UICollectionViewFlowLayout!
  
  /// Search UI button link
  var searchFab : UIButton!

  /// Coder/decoder init for use in storyboard
  required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
  }
  
  /// Initialize the button and text elements inside the place popup view.
  override func viewDidLoad() {
    
    super.viewDidLoad()
    collectionView.dataSource = self
    collectionView.delegate = self
    backButton.addTarget(self, action: #selector(self.backPressed(_:)), for: .touchUpInside)
    editButton.addTarget(self, action: #selector(self.editPressed(_:)), for: .touchUpInside)
  
    setupStyle()
    toggleEditVisibility(isHidden: true)
  
    // Add popup for search.
    self.view.addSubview(label)
    self.view.addSubview(addressLabel)
    self.view.addSubview(backButton)
    self.view.addSubview(editButton)
    self.view.addSubview(statisticsLabel)
    self.view.addSubview(collectionView)
    
  }
  
  /// Reloads the data in the statistics label
  internal func setStatistics() {
    
    let numVisits = ModelManager.shared.numberVisits(place: self.place)
    let timesString = numVisits! == 1 ? "time" : "times"
  
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    let lastVisitDate = ModelManager.shared.getLastVisitDate(placeUUID: self.place.uuid) as Date?
  
    var subtitleText = "Visited \( ModelManager.shared.getNumberVisits(placeUUID: self.place.uuid) ?? 0 ) " + timesString
    if lastVisitDate != nil {
      subtitleText += "  \u{00B7}  Last visited \( formatter.string(from: lastVisitDate!) )"
    }
  
    self.statisticsLabel.text = subtitleText
    
  }
  
  /// Update the style for the PlaceDetails card. Applies rounder corners and shadow; then sets up the frames for the collection and table views.
  internal func setupStyle() {
    
    // Setup shadow.
    Style.ApplyDropShadow(view: view)
    if let mainVC = self.parent as? MainViewController {
      Style.ApplyDropShadow(view: mainVC.editViewController.view)
    }
  
    Style.SetFullWidth(view: shadowWrap)
  
    // Setup flow layout style.
    Style.ApplyRoundedCorners(view: shadowWrap, clip: true)
    Style.ApplyRoundedCorners(view: flowWrap, clip: true)
    if let mainVC = self.parent as? MainViewController {
      Style.ApplyRoundedCorners(view: mainVC.editViewController.view, clip: true)
    }
  
    self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  
    if let mainVC = self.parent {
      if let mainVC = mainVC as? MainViewController {
        self.view.frame = CGRect(x:mainVC.timelineView.frame.minX, y: mainVC.timelineView.frame.minY - 100.0, width:mainVC.timelineView.frame.width, height:mainVC.timelineView.frame.height + 100.0)
        self.shadowWrap.frame = self.view.frame
        self.flowWrap.frame = self.view.frame
      }
    }
    
  }
  
  /// Go back to timeline or PlaceDetails. Also called after new place is selected.
  /// - parameter searchVisible: Whether the user is currently in the edit page or the details page. This determines which components to set visible.
  public func doBackPress(searchVisible: Bool) {
    
    if (searchVisible) {
      // Edit view is hidden; go back to map
      self.view.isHidden = true
      if let mainVC = self.parent {
        if let mainVC = mainVC as? MainViewController {
          mainVC.timelineView.isHidden = false
          mainVC.headerView.isHidden = false
          mainVC.reloadView()
        }
      }
      setComponentsVisible(visible: false)
    } else {
      // Edit view is on screen; go back to place details
      toggleEditVisibility(isHidden: true)
      setComponentsVisible(visible: true)
      self.collectionView.reloadData()
    }
    
  }
  
  /// Set place details UI components to be visible or hidden
  /// - parameter visible: Whether to show or hide the UI components
  public func setComponentsVisible(visible: Bool) {
    
    self.view.isHidden = !visible
    self.flowWrap.isHidden = !visible
    self.addressLabel.isHidden = !visible
    self.statisticsLabel.isHidden = !visible
    self.label.isHidden = !visible
    self.collectionView.isHidden = !visible
    
  }
  
  /// Back press target function for back UIButton
  @objc func backPressed(_ sender: UIButton!) {
    
    if let mainVC = self.parent as? MainViewController {
      doBackPress(searchVisible: mainVC.editViewController.view.isHidden)
    }
    
  }
  
  /// Show the edit view controller
  @objc func editPressed(_ sender: UIButton!) {
    
    if let mainVC = self.parent as? MainViewController {
      mainVC.headerView.isHidden = true
    }
    self.setComponentsVisible(visible: false)
    toggleEditVisibility(isHidden: false)
    Logger.shared.debug("Edit button clicked")
    
  }
  
  /// Show or hide all edit components
  /// - parameter isHidden: Whether the edit view is visible or not
  internal func toggleEditVisibility(isHidden : Bool) {
    
    if let mainVC = self.parent as? MainViewController {
      mainVC.editViewController.view.isHidden = isHidden
      mainVC.headerView.isHidden = !isHidden
    }
    
  }
  
  /// Update the place for the current location entry
  /// - parameter place: The place that the user has edited. Update the timeline to correspond to this place
  public func updatePlaceForTimelineEntry(place: Place) {
    
    // If the location entry is not closed, the end time is going to be the current time. So we supply "Date()"
    let locationEntries = ModelManager.shared.getLocationEntries(start: self.timelineEntry.startTime, end: self.timelineEntry.endTime ?? Date(), ascending: true)
    let detailsRealm = try! Realm()
    try! detailsRealm.write {
      detailsRealm.add(place)
      for entry in locationEntries {
          entry.place_id = place.uuid
      }
    }
    
  }
  
  /// Update the internal place and location
  /// - parameter place: The place to use for placeDetails
  /// - parameter timelineEntry: The timeline entry corresponding to the place that may be edited
  public func setPlaceAndLocation(place: Place, timelineEntry: TimelineEntry) {
    
    setPlace(place: place)
    setStatistics()
    self.timelineEntry = timelineEntry
    
  }

  /// Load the nearest places
  public func loadNearestPlaces() {
    
    if let mainVC = self.parent as? MainViewController {
      mainVC.editViewController.getNearestPlaces()
    }
    
  }
  
  /// Called to set the place to be displayed on the popup view
  /// - parameter place: The place to set for displaying details and edting
  public func setPlace(place: Place) {
    
    self.place = place
    self.label.text = self.place.name
    self.addressLabel.text = self.place.address
    // Get rid of the previous image
    self.placeImages.removeAll()
    
    // Now load a new image
    self.loadPhotoForPlaceID(gms_id: place.gms_id)
    self.collectionView.reloadData()
    
    // Preemptively load the nearest places for an edit operation
    loadNearestPlaces()
    
  }
}
