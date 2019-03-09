//
//  RealmTypes.swift
//  Phind
//
//  Created by Andrew B. Milich on 1/30/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

// HOW TO LOAD THE REALM DATABASE ON MAC OS X
// (also included in online docs)
// To get the realm DB location, run:
// (lldb) po myRealm.configuration.fileURL
// after pausing debugger.
// See https://stackoverflow.com/questions/28465706/how-to-find-my-realm-file

/// The RawCoordinates object is the lowest level information collected from the user through CoreMotion. It includes a latitude, longitude, movement type, and timestamp (as well as an auto-generated UUID).
public class RawCoordinates: Object {
  
  @objc dynamic var uuid = NSUUID().uuidString
  @objc dynamic var latitude : Double = -1.0
  @objc dynamic var longitude : Double = -1.0
  @objc dynamic var movement_type : String = MovementType.STATIONARY.rawValue
  @objc dynamic var timestamp : NSDate = NSDate()
  
}

/// The LocationEntry class is one level removed from the RawCoordinates; it stores a collection of RawCoordinates as well as a central latitude and longitude for the given set of coordinates. It also manages a start and end time, as well as a movement type for the set of entries.
/// Notably, LocationEntry can represent both STATIONARY locations (places like restaurants, gyms, etc.) a nd legs of commute (in which case the latitudes and longitudes will be -1.0, -1.0) and movement_type will either be AUTOMATIVE, CYCLING, or WALKING.
public class LocationEntry: Object {
  
  @objc dynamic var uuid = NSUUID().uuidString
  @objc dynamic var start : NSDate = NSDate()
  @objc dynamic var end : NSDate?
  @objc dynamic var latitude : Double = -1.0
  @objc dynamic var longitude : Double = -1.0
  @objc dynamic var movement_type : String = MovementType.STATIONARY.rawValue
  @objc dynamic var place_id : String = "<none>"      // TODO: find default
  var raw_coordinates = RealmSwift.List<RawCoordinates>()
  
}

/// The Place object stores information from external sources, such as the Google Maps API. Different location entries may correspond to the same place object, which includes an address, name, and 2D coordinate location.
public class Place: Object {
  
  @objc dynamic var uuid = NSUUID().uuidString
  @objc dynamic var gms_id : String = "<none>" // TODO find default
  @objc dynamic var name : String = ""
  @objc dynamic var address : String = ""
  @objc dynamic var latitude : Double = -1.0
  @objc dynamic var longitude : Double = -1.0
  var types = [String]()
  
}
