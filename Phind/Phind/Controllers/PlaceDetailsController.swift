//
//  MainView_PlaceDetails.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import GoogleMaps
import GooglePlaces

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
    // fatalError("init(coder:) has not been implemented")
    super.init(coder: aDecoder)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
  }
  
  // Initialize the button and text elements inside the
  // place popup view.
  override func viewDidLoad() {
    super.viewDidLoad()
    
    _ = self.view

    // TODO(Andrew) Move into init
    // TODO figure out correct frame, inset, and borders
    // self.photoCollection.frame = CGRect(x: 10, y: 120, width: 330, height: 130)
    
    self.definesPresentationContext = true
    
    // label.frame = CGRect(x: 0, y: 10, width: self.view.frame.width, height: 80)
    // label.textAlignment = .center
    //    label.font = label.font.withSize(25)
    //    label.adjustsFontSizeToFitWidth = true
    
    //    addressLabel.frame = CGRect(x: 0, y: 45, width: self.view.frame.width, height: 80)
    //    addressLabel.textAlignment = .center
    //    addressLabel.font = label.font.withSize(15)
    
    let photoSize = (self.view.frame.width - Style.PHOTO_BORDER) / 3
    print(photoSize)
    print(self.view)
    print(flowLayout)
    print(backButton)
    print(label)
    print(addressLabel)
    // flowLayout.itemSize = CGSize(width: photoSize, height: photoSize)
    
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = .white
    //    collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
    
    //    backButton.frame = CGRect(x: 10, y: 15, width: 50, height: 50)
    backButton.setImage(UIImage(named: "back.png"), for: .normal)
    //    backButton.setTitle("Back", for: .normal)
    backButton.addTarget(self, action: #selector(self.backPressed(_:)), for: .touchUpInside)
    
    //    editButton.frame = CGRect(x: width - 80, y: 15, width: 40, height: 50)
    //    editButton.setTitle("Edit", for: .normal)
    //    editButton.backgroundColor = .red
    editButton.addTarget(self, action: #selector(self.editPressed(_:)), for: .touchUpInside)
    
    self.view.addSubview(label)
    self.view.addSubview(addressLabel)
    self.view.addSubview(backButton)
    self.view.addSubview(editButton)
    self.view.addSubview(collectionView)
    self.view.backgroundColor = .white
    // self.view.isHidden = true
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
    print("Edit visible")
  }
  
  // Called to set the place to be displayed on the popup view.
  public func setPlace(place: Place) {
    self.place = place;
    self.label.text = self.place.name
    self.addressLabel.text = self.place.address
    // Get rid of the previous image
    self.placeImages.removeAll()
    self.collectionView.reloadData()
    // Now load a new image
    self.loadPhotoForPlaceID(gms_id: place.gms_id)
  }
}

