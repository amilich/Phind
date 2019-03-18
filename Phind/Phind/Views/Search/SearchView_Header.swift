//
//  SearchView_Header.swift
//  Phind
//
//  Created by Kevin Chang on 3/12/19.
//  Copyright © 2019 Team-7. All rights reserved.
//
import Foundation
import UIKit

/// Delegate, callback, and style for search view controller
internal extension SearchViewController {

  /// Setup header style
  func setupHeader() {
    
    setupSearchBar()
    setupBackFab()
    
  }
  
  /// Close search page
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
  
  /// Callback when user edits text field
  @objc func textFieldDidChange(_ textField: UITextField) {
    
      self.results = ModelManager.shared.getSearchResults(placeName: self.searchBarField.text!)!
      self.reloadView()
    
  }
  
  /// Setup button style
  func setupBackFab() {
    
      backFab = Style.CreateFab(icon: "arrow-left", backgroundColor: Style.PRIMARY_COLOR, iconColor: UIColor.white)
      Style.SetAlignment(view: backFab, align: Alignment.LEFT)
      self.view.addSubview(backFab)
      backFab.addTarget(self, action: #selector(closeSearch), for: .touchUpInside)
    
  }
  
  /// Setup search bar style
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
    self.searchBarField.placeholder = "Search locations..."
  
    // Add indentation to the text field.
    let spacerView = UIView(frame:CGRect(x:0, y:0, width: Style.ELEMENT_PADDING, height: Style.ELEMENT_PADDING))
    self.searchBarField.leftViewMode = UITextField.ViewMode.always
    self.searchBarField.leftView = spacerView
  
    self.searchBarField.delegate = self
    self.searchBarField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
    
  }
  
}

/// Callback functions for contoller to act as text field delegate
extension SearchViewController : UITextFieldDelegate {
  
  /// Return NO to disallow editing.
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    
    print("TextField should begin editing method called")
    return true
    
  }
  
  /// Field became first responder
  func textFieldDidBeginEditing(_ textField: UITextField) {
    
    print("TextField did begin editing method called")
    
  }
  
  /// Return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    
    print("TextField should snd editing method called")
    return true
    
  }
  
  /// May be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
  func textFieldDidEndEditing(_ textField: UITextField) {
    
    print("TextField did end editing method called")
    
  }
  
  /// If implemented, called in place of textFieldDidEndEditing:
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    
    print("TextField did end editing with reason method called")
    
  }
  
  /// Return NO to not change text
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
      print("While entering the characters this method gets called")
      return true
    
  }
  
  /// Called when clear button pressed. return NO to ignore (no notifications)
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    
    print("TextField should clear method called")
    return true
  }
  
  /// Called when 'return' key pressed. return NO to ignore.
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    print("TextField should return method called")
    // may be useful: textField.resignFirstResponder()
    self.view.endEditing(true)
    return true
  }
  
}
