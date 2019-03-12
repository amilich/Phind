//
//  SearchView_Header.swift
//  Phind
//
//  Created by Kevin Chang on 3/12/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import UIKit

internal extension SearchViewController {
  
  func setupHeader() {
    setupSearchBar()
  }
  
  func setupSearchBar() {
    
    print("setup search bar")
    
    // Setup search bar.
    self.searchBar = UIView()
    Style.SetFullWidth(view: self.searchBar)
    Style.ApplyDropShadow(view: self.searchBar)
    Style.ApplyRoundedCorners(view: self.searchBar, radius: Style.HEADER_HEIGHT * 0.5)
    self.view.addSubview(self.searchBar)
    self.searchBar.frame.origin.y = UIApplication.shared.windows[0].safeAreaInsets.top
    self.searchBar.frame.size.height = Style.HEADER_HEIGHT
    self.searchBar.backgroundColor = UIColor.white
    
    // Setup search bar text field.
    self.searchBarField = UITextField()
    self.searchBarField.frame.size.width = self.searchBar.frame.size.width
    self.searchBarField.frame.size.height = self.searchBar.frame.size.height
    self.searchBarField.frame.origin.x = 0
    self.searchBarField.frame.origin.y = 0
      
    self.searchBarField.font = Style.TEXT_FIELD_FONT
    self.searchBarField.borderStyle = UITextField.BorderStyle.none
    self.searchBarField.autocorrectionType = UITextAutocorrectionType.no
    self.searchBarField.keyboardType = UIKeyboardType.default
    self.searchBarField.returnKeyType = UIReturnKeyType.done
    self.searchBarField.clearButtonMode = UITextField.ViewMode.whileEditing
    self.searchBarField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
    self.searchBarField.delegate = self
    self.searchBar.addSubview(self.searchBarField)
    
  }
  
}

 extension SearchViewController : UITextFieldDelegate {
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    // return NO to disallow editing.
    print("TextField should begin editing method called")
    return true
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    // became first responder
    print("TextField did begin editing method called")
  }
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
    print("TextField should snd editing method called")
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    print("TextField did end editing method called")
  }
  
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    // if implemented, called in place of textFieldDidEndEditing:
    print("TextField did end editing with reason method called")
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    // return NO to not change text
    print("While entering the characters this method gets called")
    return true
  }
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    // called when clear button pressed. return NO to ignore (no notifications)
    print("TextField should clear method called")
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // called when 'return' key pressed. return NO to ignore.
    print("TextField should return method called")
    // may be useful: textField.resignFirstResponder()
    return true
  }

}
