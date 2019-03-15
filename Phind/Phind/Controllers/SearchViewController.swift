//
//  SearchViewController.swift
//  Phind
//
//  Created by Kevin Chang on 3/12/19.
//  Copyright © 2019 Team-7. All rights reserved.
//
import UIKit
import JustLog

class SearchViewController: UIViewController {
    
    /// The tableView stores the timeline entries.
    var tableView: UITableView!
    /// The tableWrap UIView is the first UIView encapsulating the tableView.
    var tableWrap: UIView!
    
    let TEXT_FIELD_X_MARGIN : CGFloat = 12.0
    let TEXT_FIELD_Y_MARGIN : CGFloat = 16.0
    
    var resultsView : UIView!
    var noResultsLabel : UILabel!
    
    var searchBarField : UITextField!
    var searchBar : UIView!
    var backFab : UIButton!
    
    var accessedFromEdit: Bool!
    
    var results : [Place] = []
    
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
