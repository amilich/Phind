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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.definesPresentationContext = true
    
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    label.center = CGPoint(x: 50, y: 50)
    label.text = "HELLO"
    label.textAlignment = NSTextAlignment.center
    self.view.addSubview(label)
    
  }
}
