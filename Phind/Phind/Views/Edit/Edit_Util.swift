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

/// Extend the EditViewController with functions to perform API calls.
extension EditViewController {

    /// Get a set of nearest places using the Google places API.
    public func getNearestPlaces() {
        self.results.removeAll()
        // TODO: fill in with call to nearest places API
        if let mainVC = self.parent as? MainViewController {
            if let placeDetailsVC = mainVC.placeDetailsController as? PlaceDetailsController {
                repopulateNearbyPlaces(place: placeDetailsVC.place)
                print("Got nearby places")
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
        print("calling get autocomplete places")
        if let mainVC = self.parent as? MainViewController {
            if let placeDetailsVC = mainVC.placeDetailsController as? PlaceDetailsController {
                repopulateAutocompletePlaces(query: query, place: placeDetailsVC.place)
            }
            else {
                print("Failed to get parent place.")
                return
            }
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
        if let mainVC = self.parent as? MainViewController {
            if let placeDetailsVC = mainVC.placeDetailsController as? PlaceDetailsController {
                let place = placeDetailsVC.place
                let nearbySearchUrl = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(place.latitude),\(place.longitude)&rankby=distance&key=\(Credentials.GMS_KEY)")!
                print("nearby search url: \(nearbySearchUrl)")
                
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
    
    func repopulateAutocompletePlaces(query: String, place: Place) {
        let token = GMSAutocompleteSessionToken.init()
        print("token: \(token)")
        // Create a type filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        
        var placesClient = GMSPlacesClient.shared()
        
        placesClient.findAutocompletePredictions(
            fromQuery: query, bounds: nil, boundsMode: GMSAutocompleteBoundsMode.bias,
            filter: filter, sessionToken: token, callback: { (results, error) in
                print("inside predictions")
                if let error = error {
                    print("Autocomplete error: \(error)")
                    return
                }
                if let results = results {
                    print("number of results: \(results.count)")
                    for result in results {
                        let placeId = result.placeID
                        print("place id: \(placeId)")
                        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                            UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue)
                            | UInt(GMSPlaceField.coordinate.rawValue))!

                        placesClient.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil, callback: {
                            (place: GMSPlace?, error: Error?) in
                            if let error = error {
                                print("An error occurred: \(error.localizedDescription)")
                                return
                            }
                            if let place = place {
                                print("The selected place is: \(place.name)")
                                let newPlace = Place()
                                newPlace.name = place.name!
                                newPlace.gms_id = place.placeID!
                                newPlace.address = place.formattedAddress!
                                newPlace.latitude = place.coordinate.latitude
                                newPlace.longitude = place.coordinate.longitude
                                self.results.append(newPlace)
                                self.reloadView()
                                print(self.results.count)
                            }
                        })

                    }
//                    DispatchQueue.main.async {
//                        // From the main thread, reload the data in the tableView
//                        self.reloadView()
//                    }
                    print("collected results")
                    
                }
                else {
                    print("no results")
                }
        })
    }
    }
    
//    func repopulateAutocompletePlaces(query: String, place: Place) {
//        print("at the beginning of autocomplete")
//        let token = GMSAutocompleteSessionToken.init()
//        print("token: \(token)")
//        // Create a type filter.
//        let query = "museum"
//        let filter = GMSAutocompleteFilter()
//        filter.type = .establishment
//
//        var placesClient: GMSPlacesClient!
//
//        placesClient.findAutocompletePredictions(
//            fromQuery: query, bounds: nil, boundsMode: GMSAutocompleteBoundsMode.bias,
//            filter: filter, sessionToken: token, callback: { (results, error) in
//                print("inside predictions")
//                if let error = error {
//                    print("Autocomplete error: \(error)")
//                    return
//                }
//                if let results = results {
//                    print("number of results: \(results.count)")
//                    for result in results {
//                        let placeId = result.placeID
//                        print("place id: \(placeId)")
//                        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
//                            UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue)
//                            | UInt(GMSPlaceField.coordinate.rawValue))!
//
//                        placesClient?.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil, callback: {
//                            (place: GMSPlace?, error: Error?) in
//                            if let error = error {
//                                print("An error occurred: \(error.localizedDescription)")
//                                return
//                            }
//                            if let place = place {
//                                print("The selected place is: \(place.name)")
//                                let newPlace = Place()
//                                newPlace.name = place.name!
//                                newPlace.gms_id = place.placeID!
//                                newPlace.address = place.formattedAddress!
//                                newPlace.latitude = place.coordinate.latitude
//                                newPlace.longitude = place.coordinate.longitude
//                                self.results.append(newPlace)
//                            }
//                        })
//
//                    }
//                    print("collected results")
//                    DispatchQueue.main.async {
//                        // From the main thread, reload the data in the tableView
//                        self.reloadView()
//                    }
//                }
//                else {
//                    print("no results")
//                }
//        })
//    }
//
//}


/// Given a place ID, lookup the photos for the place and add one to the UIImageview in the popup view detail.
/// - parameter gms_id: The Google place ID used to load a photo.
func loadPhotoForPlaceID(gms_id: String) {
    let token = GMSAutocompleteSessionToken.init()

}
