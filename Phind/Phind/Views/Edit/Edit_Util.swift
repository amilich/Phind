//
//  Edit_Util.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit

extension EditViewController {
  public func getNearestPlaces() {
    // TODO: fill in with call to nearest places API
    if let detailsVC = self.parent {
      if let detailsVC = detailsVC as? PlaceDetailsController {
        repopulatePlaces(place: detailsVC.place)
      } else {
        print("Failed to get parent place")
        return
      }
    } else {
      print("Failed to get parent place")
      return
    }
  }
  
  internal func repopulatePlaces(place: Place) {
    let nearbySearchUrl = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(place.latitude),\(place.longitude)&rankby=distance&key=\(Credentials.GMS_KEY)")!
    
    self.places.removeAll()
    let nearbySearchTask = sharedURLSession.dataTask(with: nearbySearchUrl) { (data, response, error) in
      
      let nearbySearchResponse = ModelManager.shared.getNearbySearchResponse(data: data, response: response, error: error)
      if nearbySearchResponse == nil {
        print("No nearby places found.")
        return
      }
      
      // Look for associated place in Realm; if it doesn't exist, create it
      let nearestPlaceResults = nearbySearchResponse!.prefix(5)
      for nearestPlaceResult in nearestPlaceResults {
        let newPlace = Place()
        newPlace.name = nearestPlaceResult["name"] as! String
        newPlace.gms_id = nearestPlaceResult["place_id"] as! String
        if let geometry = nearestPlaceResult["geometry"] as AnyObject? {
          if let location = geometry["location"] as AnyObject? {
            newPlace.latitude = location["lat"] as! Double
            newPlace.longitude = location["lng"] as! Double
          }
        }
        print("added new place \(newPlace.name)")
        self.places.append(newPlace)
        DispatchQueue.main.async {
          // From the main thread, reload the data in the tableView
          self.tableView.reloadData()
        }
      }
      
    }
    nearbySearchTask.resume()
  }
}
