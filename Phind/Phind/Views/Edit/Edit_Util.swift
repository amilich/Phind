//
//  Edit_Util.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//
import UIKit
import GoogleMaps
import GooglePlaces
import JustLog

/// Extend the EditViewController with functions to perform API calls.
extension EditViewController {
    
  /// Get a set of nearest places using the Google places API.
  public func getNearestPlaces() {
    self.results.removeAll()
    // TODO: fill in with call to nearest places API
    if let mainVC = self.parent as? MainViewController {
      if let placeDetailsVC = mainVC.placeDetailsController as? PlaceDetailsController {
        repopulateNearbyPlaces(place: placeDetailsVC.place)
        Logger.shared.verbose("Got nearby places")
      } else {
        Logger.shared.verbose("Failed to get parent place")
        return
      }
    } else {
      Logger.shared.verbose("Failed to get parent place")
      return
    }
  }
  
  /// Gets places for given autocomplete query; first checks place details controller for place
  /// - parameter query: The input query to be autocompleted
  public func getAutocompletePlaces(query: String) {
    if let mainVC = self.parent as? MainViewController {
      if let placeDetailsVC = mainVC.placeDetailsController as? PlaceDetailsController {
        repopulateAutocompletePlaces(query: query, place: placeDetailsVC.place)
      } else {
        Logger.shared.verbose("Failed to get parent place.")
        return
      }
    } else {
      Logger.shared.verbose("Failed to get parent place")
      return
    }
  }
  
  /// Search for nearby places using Google API and populate them in EditViewController internal data storage.
  /// - parameter place: Center place to search for places around.
  func repopulateNearbyPlaces(place: Place) {
    /// The URL session is required to query the Google API for nearby places
    let sharedURLSession = AppDelegate().sharedUrlSession
    if let mainVC = self.parent as? MainViewController {
      if let placeDetailsVC = mainVC.placeDetailsController as? PlaceDetailsController {
        let place = placeDetailsVC.place
        let nearbySearchUrl = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(place.latitude),\(place.longitude)&rankby=distance&key=\(Credentials.GMS_KEY)")!
      
        let nearbySearchTask = sharedURLSession.dataTask(with: nearbySearchUrl) { (data, response, error) in
          let nearbySearchResponse = ModelManager.shared.getNearbySearchResponse(data: data, response: response, error: error)
          if nearbySearchResponse == nil {
            Logger.shared.verbose("No nearby places found.")
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
            print("collected a bunch of nearby places")
            DispatchQueue.main.async {
              // From the main thread, reload the data in the tableView
              self.reloadView()
            }
          }
        }
        nearbySearchTask.resume()
      }
    }
  }
  
  /// Given the query string and current place, search for nearby autocompleted places
  /// Our query structure is derived from the Google documentation at https://developers.google.com/places/ios-sdk/client-migration
  func repopulateAutocompletePlaces(query: String, place: Place) {
    let token = GMSAutocompleteSessionToken.init()
    print("token: \(token)")
    // The type filter is used in the GooglePlaces query
    let filter = GMSAutocompleteFilter()
    filter.type = .establishment
  
    let placesClient = GMSPlacesClient.shared()
  
    placesClient.findAutocompletePredictions(
      fromQuery: query, bounds: nil, boundsMode: GMSAutocompleteBoundsMode.bias,
      filter: filter, sessionToken: token, callback: { (results, error) in
      if let error = error {
        Logger.shared.verbose("Autocomplete error: \(error)")
        return
      }
      if let results = results {
        for result in results {
          let placeId = result.placeID
          let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
              UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue)
              | UInt(GMSPlaceField.coordinate.rawValue))!
        
          placesClient.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil, callback: {
            (place: GMSPlace?, error: Error?) in
            if let error = error {
              Logger.shared.verbose("An error occurred: \(error.localizedDescription)")
              return
            }
            if let place = place {
              Logger.shared.verbose("The selected place is: \(place.name ?? "<no name>")")
              let newPlace = Place()
              newPlace.name = place.name!
              newPlace.gms_id = place.placeID!
              newPlace.address = place.formattedAddress!
              newPlace.latitude = place.coordinate.latitude
              newPlace.longitude = place.coordinate.longitude
              self.results.append(newPlace)
              self.reloadView()
            }
          })
        }
      }
    })
  }
}

/// Given a place ID, lookup the photos for the place and add one to the UIImageview in the popup view detail.
/// - parameter gms_id: The Google place ID used to load a photo.
func loadPhotoForPlaceID(gms_id: String) {
  let token = GMSAutocompleteSessionToken.init()
  // TODO do the place photo lookup
}
