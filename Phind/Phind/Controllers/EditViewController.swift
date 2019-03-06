//
//  EditViewController.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit

class EditViewController : UIViewController {
  
  @IBOutlet var shadowWrap: UIView!
  @IBOutlet var searchWrap: UIView!
  @IBOutlet var searchBar: UISearchBar!
  
  // Private variables
  let sharedURLSession = AppDelegate().sharedUrlSession
  
  // Data storage
  public var place = Place()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
