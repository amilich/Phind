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
  
  // Edit view controller
  // let editViewController = EditPlaceViewController()
  let editViewController:EditViewController = UIStoryboard(name: "Edit", bundle: nil).instantiateViewController(withIdentifier: "Edit") as! EditViewController
  
  /// Coder/decoder init for use in storyboard
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  /// Initialize the button and text elements inside the place popup view.
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.delegate = self
    
    setupStyle()
    
    backButton.addTarget(self, action: #selector(self.backPressed(_:)), for: .touchUpInside)
    editButton.addTarget(self, action: #selector(self.editPressed(_:)), for: .touchUpInside)
    
    // Register cell here so we can preemptively query for nearby places
    self.editViewController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EditCell")
    
    // Add the editViewController as a child view controller;
    // needed so edit can access parent data
    self.addChild(editViewController)
    toggleEditVisibility(isHidden: true)
    setStatistics()
    
    self.view.addSubview(label)
    self.view.addSubview(addressLabel)
    self.view.addSubview(backButton)
    self.view.addSubview(editButton)
    self.view.addSubview(statisticsLabel)
    self.view.addSubview(collectionView)
    self.view.addSubview(editViewController.searchWrap)
    self.view.addSubview(editViewController.tableView)
    self.view.addSubview(editViewController.searchBar)
    
  }
  
  /// Reloads the data in the statistics label
  internal func setStatistics() {
    let numVisits = ModelManager.shared.numberVisits(uuid: self.place.uuid)
    self.statisticsLabel.text = "\(numVisits)" // TODO
  }
  
  /// Update the style for the PlaceDetails card. Applies rounder corners and shadow; then sets up the frames for the collection and table views.
  internal func setupStyle() {
    
    // Setup shadow.
    Style.ApplyDropShadow(view: view)
    Style.ApplyDropShadow(view: editViewController.view)
    
    Style.SetFullWidth(view: shadowWrap)

    // Setup flow layout style.
    Style.ApplyRoundedCorners(view: shadowWrap, clip: true)
    Style.ApplyRoundedCorners(view: flowWrap, clip: true)
    Style.ApplyRoundedCorners(view: editViewController.view, clip: true)
    
    self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

     if let mainVC = self.parent {
       if let mainVC = mainVC as? MainViewController {
         self.view.frame = CGRect(x:mainVC.shadowWrap.frame.minX, y: mainVC.shadowWrap.frame.minY - 100.0, width:mainVC.shadowWrap.frame.width, height:mainVC.shadowWrap.frame.height + 100.0)
        self.shadowWrap.frame = self.view.frame
        self.flowWrap.frame = self.view.frame
        
        // TODO resolve the 4 and 8 constants
        // self.collectionView.frame = CGRect(x:mainVC.tableWrap.frame.minX - 2, y: mainVC.tableWrap.frame.minY + Style.DETAILS_LABEL_OFFSET, width:mainVC.tableWrap.frame.width + 2, height:Style.DETAILS_PHOTO_VIEW_HEIGHT)
        
        self.editViewController.view.frame = self.collectionView.frame
        self.editViewController.searchWrap.frame = self.editViewController.view.frame
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
          mainVC.shadowWrap.isHidden = false
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
    self.label.isHidden = !visible
    self.collectionView.isHidden = !visible
  }
  
  /// Back press target function for back UIButton
  @objc func backPressed(_ sender: UIButton!) {
    doBackPress(searchVisible: self.editViewController.searchWrap.isHidden)
  }
  
  /// Show the edit view controller
  @objc func editPressed(_ sender: UIButton!) {
    self.flowWrap.isHidden = true
    self.addressLabel.isHidden = true
    self.label.isHidden = true
    self.collectionView.isHidden = true
    
    toggleEditVisibility(isHidden: false)
    
    Logger.shared.debug("Edit button clicked")
  }
  
  /// Show or hide all edit components
  /// - parameter isHidden: Whether the edit view is visible or not
  internal func toggleEditVisibility(isHidden : Bool) {
    self.editViewController.view.isHidden = isHidden
    self.editViewController.searchWrap.isHidden = isHidden
    self.editViewController.searchBar.isHidden = isHidden
    self.editViewController.tableView.isHidden = isHidden
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
    self.timelineEntry = timelineEntry
  }
  
  /// Called to set the place to be displayed on the popup view
  /// - parameter place: The place to set for displaying details and edting
  public func setPlace(place: Place) {
    self.place = place;
    self.label.text = self.place.name
    self.addressLabel.text = self.place.address
    // Get rid of the previous image
    self.placeImages.removeAll()
    
    // Now load a new image
    self.loadPhotoForPlaceID(gms_id: place.gms_id)
    self.collectionView.reloadData()
    
    // Preemptively load the nearest places for an edit operation
    self.editViewController.getNearestPlaces()
  }
}

