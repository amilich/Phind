//
//  PhindLocationManager.swift
//  Phind
//
//  Created by Kevin Chang on 2/9/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import GoogleMaps
import GooglePlaces
import UIKit
import RealmSwift

// All application logic related to location collection is handled in here.

// TODO: Move this out into its own method.
enum MovementType : String {
  case CAR, BIKE, WALK, STATIONARY
  static let allTypes = [CAR, BIKE, WALK, STATIONARY]
}

class PhindLocationManager : NSObject, CLLocationManagerDelegate {
  
  // Minimum speed threshold for shifting between movement types.
  // All units are in meters / sec.
  let MovementThresholds : [MovementType: Double] = [
    MovementType.CAR : 9.0,
    MovementType.BIKE : 1.5,
    MovementType.WALK : 0.0
  ]
  // These indicate the distances used for locationManager.distanceFilter,
  // dependent upon the current movement type.
  let MovementDistanceFilters : [MovementType: Double] = [
    MovementType.CAR : 150,
    MovementType.BIKE : 45,
    MovementType.WALK : 30
  ]
  
  // Fields.
  public var currentMovement = MovementType.STATIONARY
  
  override init() {
    
    super.init()
    print("PhindLocationManager has been initialized.")
    
  }
  
  
  private func updateMovementType(speed: CLLocationSpeed) {
    
    // TODO: Clean this up to be less ugly.
    // Update currentMovement based on the current movement speed.
    if (speed == 0) {
      self.currentMovement = MovementType.STATIONARY
    } else {
      for movementType in MovementType.allTypes {
        // TODO: Fix this so we don't use this hacky ?? 0 thing.
        // TODO: Make sure order of enums is preserved when iterating.
        if speed > MovementThresholds[movementType] ?? 0 {
          self.currentMovement = movementType
        
          break
        }
      }
    }
    
    // Update distance filter.
    AppDelegate().locationManager.distanceFilter =
      MovementDistanceFilters[self.currentMovement] ?? 0
    
    print("Current speed: \(speed)"9)
    print("Movement upated to \(currentMovement)")
    
  }
  
  /*
   * Callback functions for location manager.
   */
  
  public func updateLocation(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    updateMovementType(speed: manager.location?.speed ?? 0.0)
    
  }
  
}
