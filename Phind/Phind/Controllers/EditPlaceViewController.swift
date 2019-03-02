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

class EditPlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  // Data storage elements
  public var place = Place()
    
  // UI components
  let backButton = UIButton()
  var tableView = UITableView()
    
    
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

    
    tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = UIColor.white
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myIdentifier")
    tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    
    self.view.addSubview(tableView)
    
  }
  
    // TODO: add table view in here with nearby places
    
  @objc func backPressed(_ sender: UIButton!) {
    self.view.isHidden = !self.view.isHidden
    print("here")
    if let popupVC = self.parent as? PlacePopupViewController {
        print("Found parent")
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

    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 5
        }
    
        internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myIdentifier", for: indexPath)
            cell.textLabel?.text = "This is row \(indexPath.row)"
            return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
}



