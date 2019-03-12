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
  
  var searchBarField : UITextField!
  var searchBar : UIView!

  override func viewDidLoad() {
    super.viewDidLoad()
    Logger.shared.verbose("Search view loaded.")

    // Setup view.
    self.view = UIView()
    self.view.backgroundColor = UIColor.clear
    
    self.setupHeader()
  }

}
