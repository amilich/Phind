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

class PlacePopupViewController: UIViewController {
  
  public var place = Place()
  let label = UILabel()
  let addressLabel = UILabel()
  // let websiteLabel = UILabel()
  let backButton = UIButton()
  
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
    self.view.backgroundColor = .white
    self.view.isHidden = true
  }
  
  @objc func pressed(_ sender: UIButton!) {
    print("Back button pressed")
    self.view.isHidden = !self.view.isHidden
  }
  
  // Called to set the place to be displayed on the popup view.
  public func setPlace(place: Place) {
    self.place = place;
    self.label.text = self.place.name
    self.addressLabel.text = self.place.address
  }
}
