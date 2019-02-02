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

class RealmLocation: Object {
    @objc dynamic var uuid = NSUUID().uuidString
    @objc dynamic var latitude : NSNumber = -1.0
    @objc dynamic var longitude : NSNumber = -1.0
    @objc dynamic var place_id : NSNumber = -1.0
    @objc dynamic var timestamp : Date = Date()
    @objc dynamic var resolved_by_human : Bool = false
}

class RealmPlace: Object {
    @objc dynamic var uuid = NSUUID().uuidString
    @objc dynamic var place_id : NSNumber = -1.0
    @objc dynamic var name : NSString = ""
    @objc dynamic var address : NSString = ""
}
