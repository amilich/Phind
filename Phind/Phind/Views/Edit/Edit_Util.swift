//
//  Edit_Util.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit

extension EditViewController {
  private func getNearestPlaces() {
    // TODO: fill in with call to nearest places API
    let nearbySearchUrl = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(self.place.latitude),\(self.place.longitude)&rankby=distance&key=\(Credentials.GMS_KEY)")!
    
    print(nearbySearchUrl)
    
    let nearbySearchTask = sharedURLSession.dataTask(with: nearbySearchUrl) { (data, response, error) in
      var nearbyPlaces = [String]()
      
      let nearbySearchResponse = ModelManager.shared.getNearbySearchResponse(data: data, response: response, error: error)
      if nearbySearchResponse == nil {
        print("No nearby places found.")
        return
      }
      
      // look for associated place in Realm; if it doesn't exist, create it
      let nearestPlaceResults = nearbySearchResponse!.prefix(5)
      
      for nearestPlaceResult in nearestPlaceResults {
        let name = nearestPlaceResult["name"] as! String
        nearbyPlaces.append(name)
        // write all to realm?
      }
      
    }
    nearbySearchTask.resume()
  }
}
