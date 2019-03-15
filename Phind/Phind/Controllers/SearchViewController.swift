//
//  SearchViewController.swift
//  Phind
//
//  Created by Kevin Chang on 3/12/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit
import JustLog

/// The UIViewController for searching for past places.
class SearchViewController: UIViewController {
  
  /// The tableView stores the timeline entries.
  var tableView: UITableView!
  /// The tableWrap UIView is the first UIView encapsulating the tableView.
  var tableWrap: UIView!
  
  /// Exclusively used in SearchView header for separating text
  let TEXT_FIELD_X_MARGIN : CGFloat = 12.0
  /// Exclusively used in SearchView header for separating text
  let TEXT_FIELD_Y_MARGIN : CGFloat = 16.0
  
  /// Outer view for encapsulating results for viewer
  var resultsView : UIView!
  /// Label if there are no results
  var noResultsLabel : UILabel!
  
  /// Raw text field for searching
  var searchBarField : UITextField!
  /// UIView for encapsulating the search bar
  var searchBar : UIView!
  /// The UI button to return to the main view
  var backFab : UIButton!
  
  /// The search results
  var results : [Place] = []

  /// Setup the UI components for the search view
  override func viewDidLoad() {
    super.viewDidLoad()
    Logger.shared.verbose("Search view loaded.")

    // Setup view.
    self.view = UIView()
    Style.SetupFullScreenView(self.view)
    self.view.backgroundColor = UIColor.clear
    
    self.setupHeader()
    self.setupResults()
  }

}
