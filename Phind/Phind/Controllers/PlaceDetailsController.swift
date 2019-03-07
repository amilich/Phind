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

class PlaceDetailsController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  // Data storage elements
  public var place = Place()
  var placeImages: [UIImage] = []
  
  // UI components
  @IBOutlet var shadowWrap: UIView!
  @IBOutlet var flowWrap: UIView!
  @IBOutlet var label: UILabel!
  @IBOutlet var addressLabel: UILabel!
  @IBOutlet var backButton: UIButton!
  @IBOutlet var editButton: UIButton!
  
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var flowLayout: UICollectionViewFlowLayout!
  
  // Edit view controller
  // let editViewController = EditPlaceViewController()
  let editViewController:EditViewController = UIStoryboard(name: "Edit", bundle: nil).instantiateViewController(withIdentifier: "Edit") as! EditViewController
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // Initialize the button and text elements inside the
  // place popup view.
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.delegate = self
    
    setupStyle()
    
    backButton.addTarget(self, action: #selector(self.backPressed(_:)), for: .touchUpInside)
    editButton.addTarget(self, action: #selector(self.editPressed(_:)), for: .touchUpInside)
    
    self.editViewController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
    
    toggleEditVisibility(isHidden: true)
    
    // Add the editViewController as a child view controller;
    // needed so edit can access parent data
    self.addChild(editViewController)
    
    self.view.addSubview(label)
    self.view.addSubview(addressLabel)
    self.view.addSubview(backButton)
    self.view.addSubview(editButton)
    self.view.addSubview(collectionView)
    self.view.addSubview(editViewController.tableView)
    self.view.addSubview(editViewController.searchBar)
    self.view.addSubview(editViewController.searchWrap)
  }
  
  internal func setupStyle() {
    // Setup shadow.
    Style.ApplyDropShadow(view: shadowWrap)
    Style.ApplyRoundedCorners(view: shadowWrap)
    Style.SetFullWidth(view: shadowWrap)
    
    // Setup flow layout style.
    Style.ApplyRoundedCorners(view: flowWrap, clip: true)
    Style.ApplyRoundedCorners(view: self.view)
    Style.ApplyRoundedCorners(view: self.editViewController.view, clip: true)
    
    self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

     if let mainVC = self.parent {
       if let mainVC = mainVC as? MainViewController {
        self.view.frame = mainVC.shadowWrap.frame
        self.shadowWrap.frame = mainVC.shadowWrap.frame
        self.flowWrap.frame = mainVC.tableWrap.frame
        
        self.collectionView.frame = CGRect(x:mainVC.tableWrap.frame.minX, y: mainVC.tableWrap.frame.minY + Style.DETAILS_LABEL_OFFSET, width:mainVC.tableWrap.frame.width, height:Style.DETAILS_PHOTO_VIEW_HEIGHT)
        
        self.editViewController.view.frame = self.collectionView.frame
        self.editViewController.searchWrap.frame = self.editViewController.view.frame
       }
     }
  }
  
  @objc func backPressed(_ sender: UIButton!) {
    
    if (self.editViewController.searchWrap.isHidden) {
      // Edit view is hidden; go back to map
      self.view.isHidden = true
      if let mainVC = self.parent {
        if let mainVC = mainVC as? MainViewController {
          mainVC.shadowWrap.isHidden = false
        }
      }
      print("Back from details")
    } else {
      // Edit view is on screen; go back to place details
      print("Back from edit view")
      self.flowWrap.isHidden = false
      self.addressLabel.isHidden = false
      self.label.isHidden = false
      
     toggleEditVisibility(isHidden: true)
    }
  }
  
  // Show the edit view controller
  @objc func editPressed(_ sender: UIButton!) {
    self.flowWrap.isHidden = true
    self.addressLabel.isHidden = true
    self.label.isHidden = true
    
    toggleEditVisibility(isHidden: false)
    
    self.flowWrap.isHidden = true
    Logger.shared.debug("Edit button clicked")
  }
  
  // Show or hide all edit components
  internal func toggleEditVisibility(isHidden : Bool) {
    self.editViewController.view.isHidden = isHidden
    self.editViewController.searchWrap.isHidden = isHidden
    self.editViewController.searchBar.isHidden = isHidden
    self.editViewController.tableView.isHidden = isHidden
  }
  
  // Called to set the place to be displayed on the popup view.
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

