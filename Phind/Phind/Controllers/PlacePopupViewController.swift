//
//  PlacePopupViewController.swift
//  Phind
//
//  Created by Andrew B. Milich on 2/17/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import GoogleMaps
import GooglePlaces

class PlacePopupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  public var place = Place()
  let label = UILabel()
  let addressLabel = UILabel()
  let backButton = UIButton()
  let flowLayout = UICollectionViewFlowLayout()
  var placeImages: [UIImage] = []
  // let imageView = UIImageView()
  
  // Initialize the button and text elements inside the
  // place popup view.
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.definesPresentationContext = true
    
    label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
    label.textAlignment = .center
    label.font = label.font.withSize(25)
    
    addressLabel.frame = CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 80)
    addressLabel.textAlignment = .center
    addressLabel.font = label.font.withSize(15)
    
    // imageView.frame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: 100)
    // imageView.contentMode = .scaleAspectFit

    // websiteLabel.frame = CGRect(x: 0, y: 80, width: UIScreen.main.bounds.width, height: 80)
    // websiteLabel.textAlignment = .center
    // websiteLabel.font = label.font.withSize(15)
    
    flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
    flowLayout.itemSize = CGSize(width: 90, height: 90)
    
    let photoCollection = UICollectionView(frame: CGRect(x: 0, y: 130, width: self.view.frame.width, height: 250), collectionViewLayout: flowLayout)
    photoCollection.dataSource = self
    photoCollection.delegate = self
    photoCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
    
    backButton.frame = CGRect(x: 10, y: 15, width: 50, height: 50)
    backButton.setImage(UIImage(named: "back.png"), for: .normal)
    backButton.setTitle("Back", for: .normal)
    backButton.addTarget(self, action: #selector(self.pressed(_:)), for: .touchUpInside)

    self.view.addSubview(label)
    self.view.addSubview(addressLabel)
    self.view.addSubview(backButton)
    self.view.addSubview(photoCollection)
    self.view.backgroundColor = .white
    self.view.isHidden = true
  }
  
  @objc func pressed(_ sender: UIButton!) {
    self.view.isHidden = !self.view.isHidden
  }
  
  // Called to set the place to be displayed on the popup view.
  public func setPlace(place: Place) {
    self.place = place;
    self.label.text = self.place.name
    self.addressLabel.text = self.place.address
    // Get rid of the previous image
    // self.imageView.image = nil // TODO set all images to NIL
    // Now load a new image
    self.loadPhotoForPlaceID(gms_id: place.gms_id)
  }
  
  // Given a place ID, lookup the photos for the place and add one
  // to the UIImageview in the popup view detail.
  func loadPhotoForPlaceID(gms_id: String) {
    GMSPlacesClient.shared().lookUpPhotos(forPlaceID: gms_id) { (photoMetadata, error) -> Void in
      if let error = error {
        print("Error: \(error.localizedDescription)")
        print(error)
      } else {
        if photoMetadata?.results != nil {
          self.placeImages.removeAll()
          let numImages = (photoMetadata?.results)!.count
          let numInGrid = min(numImages, 9)
          if numInGrid < 3 {
            self.flowLayout.itemSize = CGSize(width: 200, height: 200)
          } else if numInGrid < 6 {
            self.flowLayout.itemSize = CGSize(width: 120, height: 120)
          } else {
            self.flowLayout.itemSize = CGSize(width: 90, height: 90)
          }
          print(numImages)
          print(numInGrid)
          print(self.flowLayout.itemSize)
          
          for metadata in (photoMetadata?.results)! {
            GMSPlacesClient.shared().loadPlacePhoto(metadata, callback: { (photo, error) -> Void in
              if let error = error {
                print("Error: \(error.localizedDescription)")
                print(error)
              } else {
                print("Setting photo!")
                if photo != nil {
                  self.placeImages.append(photo!)
                }
                // self.imageView.image = photo;
              }
            })
          }
        }
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
    print("r,c = \(indexPath.row),\(indexPath.section)")
    photoCell.backgroundColor = .red
    return photoCell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // TODO scale photo when tapped
    print("TODO scale photo to screen width")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
