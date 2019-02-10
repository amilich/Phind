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
  public func appendRawCoordinates(_ locationEntry: LocationEntry, _ rawCoordinates: RawCoordinates) {
    
    try! realm.write {
      locationEntry.raw_coordinates.append(rawCoordinates)
    }
    
  }
  
  // Construct a RawCoordinates entry and add it.
  public func addRawCoordinates(_ location: CLLocation) -> RawCoordinates {
    
    let rawCoordinates = RawCoordinates()
    rawCoordinates.latitude = location.coordinate.latitude
    rawCoordinates.longitude = location.coordinate.longitude
    rawCoordinates.timestamp = NSDate()
    try! realm.write {
      realm.add(rawCoordinates)
      print("Add new RawCoordinates: (\(location.coordinate))")
    }
    return rawCoordinates
    
  }
  
}
