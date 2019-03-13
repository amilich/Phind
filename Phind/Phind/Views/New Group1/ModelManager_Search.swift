//
//  ModelManager_Search.swift
//  Phind
//
//  Created by Kevin Chang on 3/13/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation

extension ModelManager {
  
  public func getSearchResults(placeName: String = "") -> [Place]? {
    let placeEntries = Array(realm.objects(Place.self).filter("name contains[c] %@", placeName))
    return placeEntries
  }
  
  public func getNumberVisits(placeName: String = "") -> Int? {
    let placeEntry = realm.objects(Place.self).filter("name = %@", placeName).first
    let placeId = placeEntry?.uuid
    let locationEntries = Array(realm.objects(LocationEntry.self).filter("place_id = %@", placeId!))
    let numVisits = locationEntries.count
    return numVisits
  }
  
  public func getLastVisitDate(placeName: String = "", ascending: Bool = false) -> NSDate? {
    let placeEntry = realm.objects(Place.self).filter("name = %@", placeName).first
    let placeId = placeEntry?.uuid
    let locationEntries = Array(realm.objects(LocationEntry.self).filter("place_id = %@", placeId!).sorted(byKeyPath: "start", ascending: ascending))
    let lastDate = locationEntries.first!.start
    return lastDate
  }
  
  public func getVisitHistory(placeName: String = "", ascending: Bool = true) -> [LocationEntry]? {
    let placeEntry = realm.objects(Place.self).filter("name = %@", placeName).first
    let placeId = placeEntry?.uuid
    let locationEntries = realm.objects(LocationEntry.self).filter("place_id = %@", placeId!).sorted(byKeyPath: "start", ascending: ascending)
    
    return Array(locationEntries)
  }
  
}
