//
//  Edit_Util.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit

/// Extend the EditViewController with functions to perform API calls.
extension EditViewController {
    /// Get a set of nearest places using the Google places API.
    public func getNearestPlaces() {
        // TODO: fill in with call to nearest places API
        if let detailsVC = self.parent {
            if let detailsVC = detailsVC as? PlaceDetailsController {
                repopulateNearbyPlaces(place: detailsVC.place)
            } else {
                print("Failed to get parent place")
                return
            }
        } else {
            print("Failed to get parent place")
            return
        }
    }
    
    public func getAutocompletePlaces(query: String) {
        if let detailsVC = self.parent as? PlaceDetailsController {
            repopulateAutocompletePlaces(query: query, place: detailsVC.place)
        } else {
            print("Failed to get parent place")
            return
        }
    }
    
    /// Search for nearby places using Google API and populate them in EditViewController internal data storage.
    /// - parameter place: Center place to search for places around.
    func repopulateNearbyPlaces(place: Place) {
        /// The URL session is required to query the Google API for nearby places
        var sharedURLSession = AppDelegate().sharedUrlSession
        if let parent = self.parent as? PlaceDetailsController {
            let place = parent.place
            let nearbySearchUrl = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(place.latitude),\(place.longitude)&rankby=distance&key=\(Credentials.GMS_KEY)")!
            
            let nearbySearchTask = sharedURLSession.dataTask(with: nearbySearchUrl) { (data, response, error) in
                
                let nearbySearchResponse = ModelManager.shared.getNearbySearchResponse(data: data, response: response, error: error)
                if nearbySearchResponse == nil {
                    print("No nearby places found.")
                    self.results = []
                }
                
                // Look for associated place in Realm; if it doesn't exist, create it
                let nearestPlaceResults = nearbySearchResponse!.prefix(5)
                for nearestPlaceResult in nearestPlaceResults {
                    let newPlace = Place()
                    newPlace.name = nearestPlaceResult["name"] as! String
                    newPlace.gms_id = nearestPlaceResult["place_id"] as! String
                    newPlace.address = nearestPlaceResult["vicinity"] as! String
                    if let geometry = nearestPlaceResult["geometry"] as AnyObject? {
                        if let location = geometry["location"] as AnyObject? {
                            newPlace.latitude = location["lat"] as! Double
                            newPlace.longitude = location["lng"] as! Double
                        }
                    }
                    self.results.append(newPlace)
                    DispatchQueue.main.async {
                        // From the main thread, reload the data in the tableView
                        self.tableView.reloadData()
                    }
                }
                
            }
        }
    }
    
    func repopulateAutocompletePlaces(query: String, place: Place) {
        return 
    }

}
