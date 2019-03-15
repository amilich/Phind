//
//  EditViewController.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//
import UIKit

/// The EditViewController manages the search and table for a new place
class EditViewController : SearchViewController {

  /// Override the close search function so we can set proper visibility
  override func closeSearch() {
    
    if let mainVC = self.parent as? MainViewController {
      if let placeDetailsVC = mainVC.placeDetailsController as? PlaceDetailsController {
        self.results = []
        self.searchBarField.text = ""
        self.view.endEditing(true)
        self.view.isHidden = true
        placeDetailsVC.toggleEditVisibility(isHidden: true)
        placeDetailsVC.setComponentsVisible(visible: true)
        self.reloadView()
      }
    }
    
  }

  /// Performs autocomplete search when user enters text
  override func textFieldDidChange(_ textField: UITextField) {
    
    self.results.removeAll()
    self.getAutocompletePlaces(query: self.searchBarField.text!)
    self.reloadView()
    
  }
  
}
