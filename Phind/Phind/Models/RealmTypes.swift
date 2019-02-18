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

// To get the realm DB location, run:
// (lldb) po myRealm.configuration.fileURL
// after pausing debugger.
// See https://stackoverflow.com/questions/28465706/how-to-find-my-realm-file

public class RawCoordinates: Object {
  @objc dynamic var uuid = NSUUID().uuidString
  @objc dynamic var latitude : Double = -1.0
  @objc dynamic var longitude : Double = -1.0
  @objc dynamic var movement_type : String = MovementType.STATIONARY.rawValue
  @objc dynamic var timestamp : NSDate = NSDate()
}

// Notably, LocationEntry can represent both STATIONARY locations (places like restaurants, gyms, etc.)
// and legs of commute (in which case the latitudes and longitudes will be -1.0, -1.0) and movement_type
// will either be AUTOMATIVE, CYCLING, or WALKING. 
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

public class Place: Object {
  @objc dynamic var uuid = NSUUID().uuidString
  @objc dynamic var gms_id : String = "<none>" // TODO find default
  @objc dynamic var name : String = ""
  @objc dynamic var address : String = ""
  @objc dynamic var latitude : Double = -1.0
  @objc dynamic var longitude : Double = -1.0
}
