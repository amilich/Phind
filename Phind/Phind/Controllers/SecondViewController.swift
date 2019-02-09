//
//  SecondViewController.swift
//  Phind
//
//  Created by Andrew B. Milich on 1/26/19.
//  Copyright © 2019 Team-7. All rights reserved.
//
import GooglePlaces
import UIKit
import GooglePlaces

class SecondViewController: UIViewController {
  
  var placesClient: GMSPlacesClient!
  
  // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var addressLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    placesClient = GMSPlacesClient.shared()
    
    print("Second view loaded")
    
    let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
      UInt(GMSPlaceField.placeID.rawValue))!
    
    placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
      (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
      if let error = error {
        print("An error occurred: \(error.localizedDescription)")
        print(error);
        return
      }
      if let placeLikelihoodList = placeLikelihoodList {
        for likelihood in placeLikelihoodList {
          let place = likelihood.place
          print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
          print("Current PlaceID \(String(describing: place.placeID))")
        }
      }
    })
    
  }
}
