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

class RealmLocation: Object {
    @objc dynamic var uuid = NSUUID().uuidString
    @objc dynamic var location : CLLocation = CLLocation.init()
}


