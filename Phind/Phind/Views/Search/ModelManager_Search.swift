//
//  ModelManager_Search.swift
//  Phind
//
//  Created by Kevin Chang on 3/13/19.
//  Copyright © 2019 Team-7. All rights reserved.
//
import Foundation
import JustLog

/// All model functions related to search for places
extension ModelManager {

  /// Search for place with given name
  public func getSearchResults(placeName: String) -> [Place]? {
    
    let placeEntries = Array(realm.objects(Place.self).filter("name contains[c] %@", placeName))
    return placeEntries
    
  }
  
  /// Number of visits to a place
  public func getNumberVisits(placeUUID: String) -> Int? {
    
    let locationEntries = Array(realm.objects(LocationEntry.self).filter("place_id = %@ AND movement_type = 'STATIONARY'", placeUUID))
    let numVisits = locationEntries.count
    return numVisits
    
  }
  
  /// Last visit to a place
  public func getLastVisitDate(placeUUID: String, ascending: Bool = false) -> NSDate? {
    
    let locationEntries = Array(realm.objects(LocationEntry.self).filter("place_id = %@ AND movement_type = 'STATIONARY'", placeUUID)
        .sorted(byKeyPath: "start", ascending: ascending))
    if (locationEntries.count == 0) {
      Logger.shared.error("Couldn't find location entry for \(placeUUID)")
      return nil
    }
  
    let lastDate = locationEntries.first!.start
    return lastDate
    
  }
  
  /// All visits to a place stored as LocationEntries
  public func getVisitHistory(placeUUID: String, ascending: Bool = true) -> [LocationEntry]? {
    
    let placeEntry = realm.objects(Place.self).filter("uuid = %@", placeUUID).first
    let placeId = placeEntry?.uuid
    let locationEntries = realm.objects(LocationEntry.self).filter("place_id = %@ AND movement_type = 'STATIONARY'", placeId!)
        .sorted(byKeyPath: "start", ascending: ascending)
  
    return Array(locationEntries)
    
  }
  
}
