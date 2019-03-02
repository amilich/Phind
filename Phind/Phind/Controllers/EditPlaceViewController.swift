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

class EditPlaceViewController: UIViewController, UITableViewDelegate {
  
  // Data storage elements
  public var place = Place()
    
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
  // place edit view.
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
    // TODO: add table view in here with nearby places
    
  @objc func backPressed(_ sender: UIButton!) {
    self.view.isHidden = !self.view.isHidden
    print("here")
    if let popupVC = self.parent as? PlacePopupViewController {
        print("Found parent")
        print(popupVC.place.name)
        // TODO the parent of this will be the popup controller.
        // If the place is edited, the poopup controller will have
        // to refresh its content.
        // popupVC.setPlace(place: newPlace)
    }
  }
    
    // Called to set the place to be displayed on the popup view.
    public func setPlace(place: Place) {
        self.place = place;
//        self.label.text = self.place.name
//        self.addressLabel.text = self.place.address
//        // Get rid of the previous image
//        self.placeImages.removeAll()
//        self.photoCollection.reloadData()
//        // Now load a new image
//        self.loadPhotoForPlaceID(gms_id: place.gms_id)
    }

}


//extension EditPlaceViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return
//    }
//
//}
