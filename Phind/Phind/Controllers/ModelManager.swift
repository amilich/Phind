//
//  ModelManager.swift
//  Phind
//
//  All direct model manipulations (read and writes) are handled in here.
//
//  Created by Kevin Chang on 2/10/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import GoogleMaps
import GooglePlaces
import CoreMotion
import UIKit
import RealmSwift

public class ModelManager : NSObject {
  
  // Public static fields.
  
  // Singleton declaration.
  public static let shared = ModelManager()
  
  // Private fields.
  public var realm = AppDelegate().realm
  
  
  /// <section>
  /// All the read methods.
  /// </section>
  
  // Return most recent location entry.
  public func getMostRecentLocationEntry() -> LocationEntry? {
    
    let locationEntries = getLocationEntries()
    return locationEntries.count > 0 ? locationEntries[0]  : nil
    
  }
  
  // Get the GMS place name for a locationEntry by performing lookup on
  // place UUID.
  func getPlaceLabelForLocationEntry(locationEntry: LocationEntry) -> Place? {
    let placeUUID = locationEntry.place_id
    let gmsPlaces = realm.objects(Place.self)
      .filter("uuid = %@", placeUUID)
    if (gmsPlaces.count > 0) {
      return gmsPlaces[0]
    }
    return nil
  }
  
  // Return all location entries from a certain day, limited to max, and ascending default to false.
  public func getLocationEntries(from: Date = Date(), ascending: Bool = false) -> [LocationEntry] {
    
    let dayStart = Calendar.current.startOfDay(for: from)
    let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)
    let locationEntries = realm.objects(LocationEntry.self)
      .filter("start >= %@ AND start < %@", dayStart, dayEnd)
      .sorted(byKeyPath: "start", ascending: ascending)
    
    return Array(locationEntries)
    
  }
  
  // Return all stationary location entries from a certain day, limited to max, and ascending default to false.
  public func getUniqueLocationEntires(from: Date = Date(), ascending: Bool = false) -> [LocationEntry] {
    
    let dayStart = Calendar.current.startOfDay(for: from)
    let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)
    let locationEntries = realm.objects(LocationEntry.self).filter("start >= %@ AND start < %@", dayStart, dayEnd).distinct(by: ["place_id"])
    print(locationEntries)
    return Array(locationEntries)
    
  }
  
  public func mostCommonLocation(from: Date = Date(), ascending: Bool = false) -> LocationEntry {
    
    let dayStart = Calendar.current.startOfDay(for: from)
    let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)
    let locationEntries = realm.objects(LocationEntry.self)
      .filter("start >= %@ AND start < %@", dayStart, dayEnd)
      .sorted(byKeyPath: "start", ascending: ascending)
    let locationEntry = locationEntries[0]
    return locationEntry
    
  }
  
  
  // Return most recent location entry.
  public func getMostRecentRawCoord() -> RawCoordinates? {
    
    let rawCoordinates = getRawCoords()
    return rawCoordinates.count > 0 ? rawCoordinates[0]  : nil
    
  }
  
  // Return all location entries from a certain day, limited to max, and ascending default to false.
  public func getRawCoords(from: Date = Date(), ascending: Bool = false) -> [RawCoordinates] {
    
    let dayStart = Calendar.current.startOfDay(for: from)
    let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)
    let rawCoordinates = realm.objects(RawCoordinates.self)
      .filter("timestamp >= %@ AND timestamp < %@", dayStart, dayEnd)
      .sorted(byKeyPath: "timestamp", ascending: ascending)
    
    return Array(rawCoordinates)
    
  }
  
  /// <section>
  /// All the write methods.
  /// </section>
  
  // Close up previous LocationEntry if necessary by adding an end time.
  public func closeLocationEntry(_ locationEntry: LocationEntry) {
    
    // Close up last location entry if one is provided to this function.
    try! realm.write {
      locationEntry.end = NSDate()
      print("LocationEntry closed.")
    }
    
  }
  
  private func getLikelyPlaceList(placeLikelihoodList: Array<GMSPlaceLikelihood>) -> [Place]{
    var likelyPlaces = [Place]()
    for likelihood in placeLikelihoodList {
      let place = likelihood.place
      print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
      print("Current PlaceID \(String(describing: place.placeID))")
      
      let likelyPlace = Place()
      likelyPlace.gms_id = place.placeID ?? "" // TODO need default value
      likelyPlace.name = place.name ?? ""
      likelyPlace.address = place.formattedAddress ?? ""
      likelyPlaces.append(likelyPlace);
    }
    return likelyPlaces
  }
  
  public func addLocationEntry(_ rawCoordinates: RawCoordinates,
                               _ currMovementType: MovementType) -> LocationEntry{
    let locationEntry = LocationEntry()
    
    locationEntry.start = NSDate()
    locationEntry.longitude = rawCoordinates.longitude
    locationEntry.latitude = rawCoordinates.latitude
    locationEntry.movement_type = currMovementType.rawValue
    locationEntry.raw_coordinates.append(rawCoordinates)
    
    try! self.realm.write {
      self.realm.add(locationEntry)
      print("Add new LocationEntry: (\(locationEntry.uuid))")
    }
    return locationEntry
  }
  
  // TODO
  //    public func getPlaceFromCoordinates() {
  //
  //    }
  
  public func assignPlaceIdToCurrentLocation(_ locationEntry: LocationEntry) {
    let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
      UInt(GMSPlaceField.placeID.rawValue))!
    
    GMSPlacesClient.shared().findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
      (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
      
      if let error = error {
        print("An error occurred: \(error.localizedDescription)")
        return
      }
      if let placeLikelihoodList = placeLikelihoodList {
        
        var likelyPlaces = self.getLikelyPlaceList(placeLikelihoodList: placeLikelihoodList)
        
        
        if likelyPlaces.count > 0 {
          print(likelyPlaces[0].name)
          // TODO: consider place likelihoods instead of only grabbing first
          
          var place = self.realm.objects(Place.self).filter("gms_id = %@", likelyPlaces[0].gms_id).first
          if place == nil {
            place = Place()
            place!.address = likelyPlaces[0].address
            place!.name = likelyPlaces[0].name
            place!.gms_id = likelyPlaces[0].gms_id
            
            try! self.realm.write {
              self.realm.add(place!)
            }
          }
          
          // Link place id to location entry.
          try! self.realm.write {
            locationEntry.place_id = place!.uuid
            print("Add new LocationEntry: (\(locationEntry.uuid)) with place_id (\(likelyPlaces[0].uuid))")
          }
        }
        else {
          print("No places found for coordinates.")
        }
        
      }
    })
  }
  
  // Append a RawCoordinates to a LocationEntry.
  public func appendRawCoord(_ locationEntry: LocationEntry, _ rawCoord: RawCoordinates) {
    
    try! realm.write {
      locationEntry.raw_coordinates.append(rawCoord)
    }
    
  }
  
  // Construct a RawCoordinates entry and add it.
  public func addRawCoord(_ location: CLLocation) -> RawCoordinates {
    
    let rawCoord = RawCoordinates()
    rawCoord.latitude = location.coordinate.latitude
    rawCoord.longitude = location.coordinate.longitude
    rawCoord.timestamp = NSDate()
    try! realm.write {
      realm.add(rawCoord)
      print("Add new RawCoordinates: (\(location.coordinate))")
    }
    return rawCoord
    
  }
  
}
