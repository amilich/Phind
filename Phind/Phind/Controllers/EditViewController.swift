//
//  EditViewController.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit


class EditViewController : SearchViewController {
    
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
    
    func textFieldDidChange(_ textField: UITextField) {
        self.getAutocompletePlaces(query: self.searchBarField.text!)
        self.reloadView()
    }
        
        
}

}
