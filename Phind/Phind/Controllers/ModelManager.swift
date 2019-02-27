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
import JustLog

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
  public func getMostRecentLocationEntry(from: Date = Date()) -> LocationEntry? {
    
    let locationEntries = getLocationEntries(from: from)
    return locationEntries.count > 0 ? locationEntries[0]  : nil
    
  }
  
  public func getCoordForPlace(uuid: String) -> CLLocationCoordinate2D? {
    let placesWithUuid = realm.objects(LocationEntry.self)
      .filter("place_id = %@", uuid)
    if (placesWithUuid.count > 0) {
      return CLLocationCoordinate2D(latitude: placesWithUuid[0].latitude, longitude: placesWithUuid[0].longitude)
    }
    return nil
  }
  
  public func getPlaceWithUUID(uuid: String) -> Place? {
    let gmsPlaces = realm.objects(Place.self)
      .filter("uuid = %@", uuid)
    if (gmsPlaces.count > 0) {
      return gmsPlaces[0]
    }
    return nil
  }
  
  // Get the GMS place name for a locationEntry by performing lookup on
  // place UUID.
  func getPlace(locationEntry: LocationEntry) -> Place? {
    let placeUUID = locationEntry.place_id
    return getPlaceWithUUID(uuid: placeUUID)
  }
  
  // Return all location entries from a certain period, limited to max, and ascending default to false.
  public func getLocationEntries(from: Date = Date(), number_of_days: Int = -1, ascending: Bool = false) -> [LocationEntry] {
    
    let dayStart = Calendar.current.startOfDay(for: from)
    var dayEnd = Date()
    if number_of_days > 0 {
      dayEnd = Calendar.current.date(byAdding: .day, value: number_of_days, to: dayStart)!
    }
    
    let locationEntries = realm.objects(LocationEntry.self)
      .filter("start >= %@ AND start < %@", dayStart, dayEnd)
      .sorted(byKeyPath: "start", ascending: ascending)
    
    var locationEntriesArr = Array(locationEntries)
    locationEntriesArr.sort(
      by: { $0.start.compare($1.start as Date) == ComparisonResult.orderedAscending }
    )
    
    return locationEntriesArr
    
    
  }
  
  // Return all stationary location entries from a certain day, limited to max, and ascending default to false.
  public func getUniqueLocationEntires(from: Date = Date(), ascending: Bool = false) -> [LocationEntry] {
    
    let dayStart = Calendar.current.startOfDay(for: from)
    let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)
    let locationEntries = realm.objects(LocationEntry.self).filter("start >= %@ AND start < %@", dayStart, dayEnd).distinct(by: ["place_id"])
    return Array(locationEntries)
    
  }
  
  public func mostCommonLocation(from: Date = Date(), ascending: Bool = false) -> LocationEntry? {
    
    let dayStart = Calendar.current.startOfDay(for: from)
    let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)
    let locationEntries = realm.objects(LocationEntry.self)
      .filter("start >= %@ AND start < %@", dayStart, dayEnd)
      .sorted(byKeyPath: "place_id", ascending: ascending)
    if locationEntries.count <= 0{
      return nil
    }
    var bestLocationEntry = locationEntries[0]
    var max_count = 0
    var count = 0
    var lastLocationEntry = locationEntries[0]
    for locationEntry in locationEntries{
      if locationEntry.place_id == lastLocationEntry.place_id{
        count = count + 1
      }else{
        count = 1
      }
      lastLocationEntry = locationEntry
      if count > max_count{
        max_count = count
        bestLocationEntry = locationEntry
      }
    }
        return bestLocationEntry
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
    
    Logger.shared.verbose("Attempt to close location entry.")
    // Close up last location entry if one is provided to this function.
    try! realm.write {
      locationEntry.end = NSDate()
      Logger.shared.verbose("LocationEntry closed.")
    }
    
  }
  
  private func getLikelyPlaceList(placeLikelihoodList: Array<GMSPlaceLikelihood>) -> [Place]{
    var likelyPlaces = [Place]()
    for likelihood in placeLikelihoodList {
      let place = likelihood.place
//      print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
//      print("Current PlaceID \(String(describing: place.placeID))")
      
      let likelyPlace = Place()
      likelyPlace.gms_id = place.placeID ?? "" // TODO need default value
      likelyPlace.name = place.name ?? ""
      likelyPlace.address = place.formattedAddress ?? ""
      likelyPlace.latitude = place.coordinate.latitude
      likelyPlace.longitude = place.coordinate.longitude
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
      Logger.shared.verbose("Add new LocationEntry: (\(locationEntry.uuid))")
    }
    return locationEntry
  }
  
  // TODO
  //    public func getPlaceFromCoordinates() {
  //
  //    }
  
  public func assignPlaceIdToCurrentLocation(_ locationEntry: LocationEntry) {
    let fields: GMSPlaceField = GMSPlaceField(rawValue:
            UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.formattedAddress.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue))!
    
    print("Assigning place IDs to location")
    GMSPlacesClient.shared().findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
      (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
      
      if let error = error {
        Logger.shared.error("An error occurred in assigning location: \(error.localizedDescription)")
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
            place!.latitude = likelyPlaces[0].latitude
            place!.longitude = likelyPlaces[0].longitude
            
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
      Logger.shared.verbose("Add new RawCoordinates: (\(location.coordinate))")
    }
    return rawCoord
    
  }
  
}
