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
        
        
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let place = self.results[indexPath.item]
//        self.closeSearch()
//        if let mainVC = self.parent {
//            if let mainVC = mainVC as? MainViewController {
//                
//                let visitHistory = ModelManager.shared.getVisitHistory(placeUUID: place.uuid)!
//                if visitHistory.count == 0 {
//                    return
//                }
//                let latestVisit = visitHistory[0]
//                let timelineEntry = TimelineEntry(
//                    placeUUID: place.uuid,
//                    placeLabel: place.name,
//                    startTime: latestVisit.start as Date,
//                    endTime: latestVisit.end as Date?,
//                    movementType: latestVisit.movement_type
//                )
//                
//                mainVC.placeDetailsController.setPlaceAndLocation(place: place, timelineEntry: timelineEntry)
//                mainVC.timelineView.isHidden = true
//                mainVC.placeDetailsController.setComponentsVisible(visible: true)
//                
//            }
//        }
//        
//    }
}

}
