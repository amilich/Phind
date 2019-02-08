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

class RealmLikelyPlace: Object {
    @objc dynamic var name : String = "<name>" // TODO find default
    @objc dynamic var address : String = "<name>" // TODO find default
    @objc dynamic var place_id : String = "<place_id>" // TODO find default
    @objc dynamic var likelihood : Double = 0.0
}

class RealmLocation: Object {
    @objc dynamic var uuid = NSUUID().uuidString
    @objc dynamic var latitude : Double = -1.0
    @objc dynamic var longitude : Double = -1.0
    @objc dynamic var place_id : String = "<none>" // TODO find default
    @objc dynamic var timestamp : Date = Date()
    @objc dynamic var resolved_by_human : Bool = false
    let likelyPlaces = List<RealmLikelyPlace>()
    
}

class RealmPlace: Object {
    @objc dynamic var uuid = NSUUID().uuidString
    @objc dynamic var place_id : String = "<none>" // TODO find default
    @objc dynamic var name : String = ""
    @objc dynamic var address : String = ""
}
