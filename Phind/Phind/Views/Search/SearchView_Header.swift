//
//  SearchView_Header.swift
//  Phind
//
//  Created by Kevin Chang on 3/12/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import UIKit

/// All header components and functions for the SearchViewController
internal extension SearchViewController {
  
  /// Wrapper function for setting up the input field and back button
  func setupHeader() {
    setupSearchBar()
    setupBackFab()
  }
  
  /// Close the search view and return to main view
  @objc func closeSearch() {
    
    if let mainVC = self.parent {
      if let mainVC = mainVC as? MainViewController {
        
        self.results = []
        self.reloadView()
        self.searchBarField.text = ""
        self.view.endEditing(true)
        mainVC.svc.view.isHidden = true
        mainVC.toggleVisibility(hidden: false)
        
      }
    }
    
  }
  
  /// Triggered when user types into the text field
  @objc func textFieldDidChange(_ textField: UITextField) {
    
    self.results = ModelManager.shared.getSearchResults(placeName: self.searchBarField.text!)!
    self.reloadView()
    
  }
  
  /// Setup and format the back button
  func setupBackFab() {
    
    backFab = Style.CreateFab(icon: "arrow-left", backgroundColor: Style.PRIMARY_COLOR, iconColor: UIColor.white)
    Style.SetAlignment(view: backFab, align: Alignment.LEFT)
    self.view.addSubview(backFab)
    backFab.addTarget(self, action: #selector(closeSearch), for: .touchUpInside)
    
  }
  
  /// Setup and format the search bar
  func setupSearchBar() {

    // Setup search bar.
    self.searchBar = UIView()
    Style.SetPartialWidth(view: self.searchBar, offset: Style.FAB_HEIGHT)
    Style.SetAlignment(
      view: self.searchBar,
      offsetX: Style.FAB_HEIGHT + Style.ELEMENT_MARGIN,
      align: Alignment.RIGHT
    )
    
    Style.ApplyDropShadow(view: self.searchBar)
    Style.ApplyRoundedCorners(view: self.searchBar, radius: Style.HEADER_HEIGHT * 0.5)
    self.view.addSubview(self.searchBar)
    
    self.searchBar.frame.size.height = Style.HEADER_HEIGHT
    self.searchBar.backgroundColor = UIColor.white
    
    // Setup search bar text field.
    self.searchBarField = UITextField(frame: CGRect(
      x: TEXT_FIELD_X_MARGIN,
      y: TEXT_FIELD_Y_MARGIN,
      width: self.searchBar.frame.size.width - TEXT_FIELD_X_MARGIN * 2.0,
      height: self.searchBar.frame.size.height - TEXT_FIELD_Y_MARGIN * 2.0
    ))
    Style.SetupTextField(textField: self.searchBarField)
    self.searchBar.addSubview(self.searchBarField)
    self.searchBar.bringSubviewToFront(self.searchBarField)
    self.searchBarField.placeholder = "Search past locations..."
    
    // Add indentation to the text field.
    let spacerView = UIView(frame:CGRect(x:0, y:0, width: Style.ELEMENT_PADDING, height: Style.ELEMENT_PADDING))
    self.searchBarField.leftViewMode = UITextField.ViewMode.always
    self.searchBarField.leftView = spacerView
    
    self.searchBarField.delegate = self
    self.searchBarField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
    
  }
  
}

/// Extension for the SearchViewController to act as a delegate for the text field
extension SearchViewController : UITextFieldDelegate {
  
  /// Called when user can edit text field
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    // return NO to disallow editing.
    print("TextField should begin editing method called")
    return true
  }
  
  /// Called when user edits value in text field
  func textFieldDidBeginEditing(_ textField: UITextField) {
    // became first responder
    print("TextField did begin editing method called")
  }
  
  /// Called right when editing is not allowed anymore
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
    print("TextField should snd editing method called")
    return true
  }
  
  /// Called when user finishes editing
  func textFieldDidEndEditing(_ textField: UITextField) {
    // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    print("TextField did end editing method called")
  }
  
  /// Called when user ends editing, butw ith specific reason
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    // if implemented, called in place of textFieldDidEndEditing:
    print("TextField did end editing with reason method called")
  }
  
  /// Called right after the user enters a character
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    // return NO to not change text
    print("While entering the characters this method gets called")
    return true
  }
  
  // When user clears text field
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    // called when clear button pressed. return NO to ignore (no notifications)
    print("TextField should clear method called")
    return true
  }
  
  /// Called after return button on keyboard is pressed
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // called when 'return' key pressed. return NO to ignore.
    print("TextField should return method called")
    // may be useful: textField.resignFirstResponder()
    self.view.endEditing(true)
    return true
  }

}
