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
  
  // Return all location entries from a certain day, limited to max, and ascending default to false.
  public func getLocationEntries(from: Date = Date(), ascending: Bool = false) -> [LocationEntry] {
    
    let dayStart = Calendar.current.startOfDay(for: from)
    let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)
    let locationEntries = realm.objects(LocationEntry.self)
      .filter("start >= %@ AND start < %@", dayStart, dayEnd)
      .sorted(byKeyPath: "start", ascending: ascending)
    
    return Array(locationEntries)
    
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
  
  // Create a new LocationEntry and close up previous LocationEntry if necessary.
  public func addLocationEntry(_ rawCoordinates: RawCoordinates,
                               _ currMovementType: MovementType) -> LocationEntry {
    
    // TODO: Need to search for PlaceID and add it in here as well.
    let locationEntry = LocationEntry()
    locationEntry.start = NSDate()
    locationEntry.longitude = rawCoordinates.longitude
    locationEntry.latitude = rawCoordinates.latitude
    locationEntry.movement_type = currMovementType.rawValue
    try! realm.write {
      realm.add(locationEntry)
      print("Add new LocationEntry: (\(locationEntry.uuid))")
    }
    
    return locationEntry
    
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
