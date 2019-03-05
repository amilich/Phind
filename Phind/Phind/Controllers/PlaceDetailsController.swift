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
    
    self.view.addSubview(label)
    self.view.addSubview(addressLabel)
    self.view.addSubview(backButton)
    self.view.addSubview(editButton)
    self.view.addSubview(collectionView)
  }
  
  internal func setupStyle() {
    // Setup shadow.
    Style.ApplyDropShadow(view: shadowWrap)
    Style.ApplyRoundedCorners(view: shadowWrap)
    Style.SetFullWidth(view: shadowWrap)
    
    // Setup flow layout style.
    Style.ApplyRoundedCorners(view: flowWrap, clip: true)
    Style.ApplyRoundedCorners(view: self.view)
    
    self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

     if let mainVC = self.parent {
       if let mainVC = mainVC as? MainViewController {
        self.view.frame = mainVC.shadowWrap.frame
        self.shadowWrap.frame = mainVC.shadowWrap.frame
        self.flowWrap.frame = mainVC.tableWrap.frame
        self.collectionView.frame = CGRect(x:mainVC.tableWrap.frame.minX, y: mainVC.tableWrap.frame.minY + Style.DETAILS_LABEL_OFFSET, width:mainVC.tableWrap.frame.width, height:Style.DETAILS_PHOTO_VIEW_HEIGHT)
       }
     }
  }
  
  @objc func backPressed(_ sender: UIButton!) {
    self.view.isHidden = !self.view.isHidden
    if let mainVC = self.parent {
      if let mainVC = mainVC as? MainViewController {
        mainVC.shadowWrap.isHidden = false
      }
    }
  }
  
  // Show the edit view controller
  @objc func editPressed(_ sender: UIButton!) {
    // self.editViewController.view.isHidden = false
    Logger.shared.debug("Edit button clicked")
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
  }
}

