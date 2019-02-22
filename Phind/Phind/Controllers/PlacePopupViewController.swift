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

class PlacePopupViewController: UIViewController {
  
  public var place = Place()
  let label = UILabel()
  let addressLabel = UILabel()
  let backButton = UIButton()
  let imageView = UIImageView()
  
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
    
    imageView.frame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: 100)
    imageView.contentMode = .scaleAspectFit

    // websiteLabel.frame = CGRect(x: 0, y: 80, width: UIScreen.main.bounds.width, height: 80)
    // websiteLabel.textAlignment = .center
    // websiteLabel.font = label.font.withSize(15)
    
    backButton.frame = CGRect(x: 10, y: 15, width: 50, height: 50)
    backButton.setImage(UIImage(named: "back.png"), for: .normal)
    backButton.setTitle("Back", for: .normal)
    backButton.addTarget(self, action: #selector(self.pressed(_:)), for: .touchUpInside)

    self.view.addSubview(label)
    self.view.addSubview(addressLabel)
    self.view.addSubview(backButton)
    self.view.addSubview(imageView)
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
    self.imageView.image = nil
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
        if let metadata = photoMetadata?.results.first {
          GMSPlacesClient.shared().loadPlacePhoto(metadata, callback: { (photo, error) -> Void in
            if let error = error {
              print("Error: \(error.localizedDescription)")
              print(error)
            } else {
              self.imageView.image = photo;
            }
          })
        }
      }
    }
  }
}
