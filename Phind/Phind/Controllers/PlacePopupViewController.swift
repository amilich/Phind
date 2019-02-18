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
  let backButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.definesPresentationContext = true
    
    label.frame = CGRect(x: 100, y: 300, width: 100, height: 100)
    label.text = "HELLO"
    label.textAlignment = NSTextAlignment.center
    
    backButton.frame = CGRect(x: 10, y: 10, width: 50, height: 25)
    backButton.backgroundColor = .green
    backButton.addTarget(self, action: #selector(self.pressed(_:)), for: .touchUpInside)
    // backButton.setTitle("Back", for: UIControl.State.Normal)
    
    self.view.addSubview(label)
    self.view.addSubview(backButton)
    self.view.backgroundColor = .white
    self.view.isHidden = true
  }
  
  @objc func pressed(_ sender: UIButton!) {
    print("Back button pressed")
    self.view.isHidden = !self.view.isHidden
  }
  
  public func setPlace(place: Place) {
    self.place = place;
    print("Label place set to \(place.name)")
    self.label.text = self.place.name
  }
}
