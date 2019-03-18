//
//  SearchViewController.swift
//  Phind
//
//  Created by Kevin Chang on 3/12/19.
//  Copyright © 2019 Team-7. All rights reserved.
//
import UIKit
import JustLog

/// Main UI controller for extensible search view
class SearchViewController: UIViewController {
    
  /// The tableView stores the timeline entries.
  var tableView: UITableView!
  /// The tableWrap UIView is the first UIView encapsulating the tableView.
  var tableWrap: UIView!

  /// X margin for text input field
  let TEXT_FIELD_X_MARGIN : CGFloat = 12.0
  /// Y margin for text input field
  let TEXT_FIELD_Y_MARGIN : CGFloat = 16.0
  
  /// UIView to contain results
  var resultsView : UIView!
  /// UILabel if no results
  var noResultsLabel : UILabel!
  /// Text field for user input
  var searchBarField : UITextField!
  /// UIView containing search bar
  var searchBar : UIView!
  /// Back button to exit
  var backFab : UIButton!
  /// Whether user accessed page from edit page
  var accessedFromEdit: Bool!
  /// Results array for search
  var results : [Place] = []
  
  /// Setup style for search reuslts and load initial data
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
