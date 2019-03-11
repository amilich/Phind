//
//  EditViewController.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit

/// The EditViewController becomes a child UIViewController of the PlaceDetailsController. It manages all components and functions related to editing a timeline entry.
class EditViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
  
  /// UIView wrapper for the search bar
  @IBOutlet var searchWrap: UIView!
  /// UI component for the search bar
  @IBOutlet var searchBar: UISearchBar!
  /// UITableView for displaying options for editing
  @IBOutlet var tableView: UITableView!
  
  // Private variables
  /// The URL session is required to query the Google API for nearby places
  let sharedURLSession = AppDelegate().sharedUrlSession
  
  // Data storage
  /// The places array stores all nearby places displayed to the user
  var places = [Place]()
  
  /// Setup the data linkages to UI components
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.searchBar.delegate = self
  }
  
  /// Returns table cell height
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    // TODO: Make this a constant.
    return 64.0
  }

  /// Called when the user selects a place (which means they want to edit the timelineEntry)
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedIdx = indexPath[1]
    if let detailsVC = self.parent {
      if let detailsVC = detailsVC as? PlaceDetailsController {
        // Load the parent VC and update its details
        let newPlace = self.places[selectedIdx]
        detailsVC.setPlace(place: newPlace)
        detailsVC.updatePlaceForTimelineEntry(place: newPlace)
        detailsVC.doBackPress(searchVisible: false)
      }
    }
  }
  
  /// Return the number of items in the table
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.places.count
  }
  
  /// Dequeue a table cell and format it properly
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let placeCell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
    placeCell.textLabel?.text = self.places[indexPath.item].name
    return placeCell
  }
}
