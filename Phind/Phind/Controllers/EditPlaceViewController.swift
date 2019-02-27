//
//  EditPlaceViewController.swift
//  Phind
//
//  Created by Andrew B. Milich on 2/27/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import GoogleMaps
import GooglePlaces

class EditPlaceViewController: UIViewController {
  
  // UI components
  let backButton = UIButton()
  
  init() {
    super.init(nibName: nil, bundle: nil)
    
    self.definesPresentationContext = true
    
    backButton.frame = CGRect(x: 10, y: 15, width: 50, height: 50)
    backButton.setImage(UIImage(named: "back.png"), for: .normal)
    backButton.setTitle("Back", for: .normal)
    backButton.addTarget(self, action: #selector(self.backPressed(_:)), for: .touchUpInside)
    
    self.view.addSubview(backButton)
    self.view.backgroundColor = .white
    self.view.isHidden = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Initialize the button and text elements inside the
  // place popup view.
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @objc func backPressed(_ sender: UIButton!) {
    self.view.isHidden = !self.view.isHidden
    if let popupVC = self.parent {
      if let popupVC = popupVC as? PlacePopupViewController {
        print("Found parent")
      }
    }
    // TODO the parent of this will be the popup controller.
    // If the place is edited, the poopup controller will have
    // to refresh its content.
  }
}
