//
//  EditViewController.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit

class EditViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
  
  @IBOutlet var searchWrap: UIView!
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var tableView: UITableView!
  
  // Private variables
  let sharedURLSession = AppDelegate().sharedUrlSession
  
  // Data storage
  var places = [Place]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.searchBar.delegate = self
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    // TODO: Make this a constant.
    return 64.0
  }
  
  // Called when you tap a row in the table; displays the place popup
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedIdx = indexPath[1]
    print("Tapped \(selectedIdx)")
    if let detailsVC = self.parent {
      if let detailsVC = detailsVC as? PlaceDetailsController {
        let newPlace = self.places[selectedIdx]
        detailsVC.setPlace(place: newPlace)
        detailsVC.updatePlaceForTimelineEntry(place: newPlace)
        detailsVC.doBackPress(searchVisible: false)
      }
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.places.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let placeCell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
    placeCell.textLabel?.text = self.places[indexPath.item].name
    return placeCell
  }
}
