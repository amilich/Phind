//
//  PhindLocationManager.swift
//  Phind
//
//  All application logic related to location collection is handled in here.
//
//  Created by Kevin Chang on 2/9/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import GoogleMaps
import GooglePlaces
import CoreMotion
import UIKit
import RealmSwift

// Motion activites based on Apple definitions here: https://apple.co/2SlBGg2
public enum MovementType : String {
  case AUTOMOTIVE, CYCLING, WALKING, STATIONARY
  static let allTypes = [AUTOMOTIVE, CYCLING, WALKING, STATIONARY]
}

public class PhindLocationManager : NSObject, CLLocationManagerDelegate {
  
  // Public static fields.
  
  // Singleton declaration.
  public static let shared = PhindLocationManager()
  public static let DEFAULT_DISTANCE_FILTER : CLLocationDistance = 15
  // Minimum threshold for a new location to register as a new LocationEntry (in meters).
  #if targetEnvironment(simulator)
  public static let NOTABLE_DISTANCE_THRESHOLD = 5.0
  #else
  public static let NOTABLE_DISTANCE_THRESHOLD = 100.0
  #endif
  
  // Private constants.
  // We only allow locations for which
  // (distance delta)/(time delta) * SPEED_BUFFER < real measured speed
  // to avoid GPS bugs from skewing our results.
  private let SPEED_BUFFER = 3.0
  
  // These are the distances used for locationManager.distanceFilter,
  // dependent upon the current movement type.
  let MV_DISTANCE_FILTERS: [MovementType:Double] = [
    MovementType.AUTOMOTIVE : 150.0,
    MovementType.CYCLING    : 45.0,
    MovementType.WALKING    : 30.0,
    MovementType.STATIONARY : DEFAULT_DISTANCE_FILTER
  ]
  
  // Public fields.
  public private(set) var currMovementType = MovementType.STATIONARY
  
  // Private fields.
  private var locationManager = AppDelegate().locationManager
  private var realm = AppDelegate().realm
  
  
  // Default Swift constructor for classes.
  override init() {
    super.init()
    print("PhindLocationManager has been initialized.")
  }
  
  // Update movement type based on CMMotionActivity passed in from AppDelegate.
  public func updateMovementType(motion: CMMotionActivity) {
    
    // Update currMovementType based CoreMotion-reported motion type.
    var movementType : MovementType
    if motion.walking {
      movementType = MovementType.WALKING
    } else if motion.cycling {
      movementType = MovementType.CYCLING
    } else if motion.automotive {
      movementType = MovementType.AUTOMOTIVE
    } else {
      movementType = MovementType.STATIONARY
    }
    
    if movementType != currMovementType {
      // Update distance filter if movement type is different.
      currMovementType = movementType
      locationManager.distanceFilter = MV_DISTANCE_FILTERS[currMovementType] ?? 0
      print("Movement type switched to: \(currMovementType)")
    }
    
  }
  
  // Update location entries based on CLLocation. If location data indicates new location,
  // then close the latest LocationEntry by adding a departure time and create a new LocationEntry.
  // In all cases, add in a new rawCoord entry.
  private func updateLocation(location: CLLocation) {
    
    let rawCoord = ModelManager.shared.addRawCoord(location)
    
    // Check latest location entry in realm objects, from today.
    let lastLocationEntry = ModelManager.shared.getMostRecentLocationEntry()
    var currLocationEntry : LocationEntry? = lastLocationEntry
    
    // Update and create new LocationEntries depending on whether or not
    // lastLocationEntry exists and the distance between last location (if it exists)
    // and the current location.
    if (lastLocationEntry != nil) {
      print(lastLocationEntry?.movement_type ?? "")
      
      // If last location exists, check how far the current location is from it.
      let lastLocation = CLLocation(
        latitude: lastLocationEntry?.latitude ?? -1.0,
        longitude: lastLocationEntry?.longitude ?? -1.0
      )
      let distanceFromLastLocation = lastLocation.distance(from: location)
      print(distanceFromLastLocation)
      
      // If the distance between the location of the most recent LocationEntry and the current
      // coordinates is greater than NOTABLE_DISTANCE_THRESHOLD, then need to evaluate a few cases
      // to determine what is happening.
      if (distanceFromLastLocation >= PhindLocationManager.NOTABLE_DISTANCE_THRESHOLD) {
        if lastLocationEntry?.movement_type == currMovementType.rawValue {
          if currMovementType != MovementType.STATIONARY {
            // Case 1: Move from non-stationary to non-stationary.
            // This means the user was moving and is still moving, and as such, we will simply append
            // the raw coord to the last location entry.
            print("Case 1: NON-STATIONARY TO NON-STATIONARY")
            currLocationEntry = lastLocationEntry!
          } else {
            // Case 2: Move from stationary to stationary.
            // This means the user has hopped from one stationary location to another, with a distance
            // > NOTABLE_DISTANCE_THRESHOLD in between the two. This is unlikely to happen, since
            // there would likely be some mode of movement in between. It is likely this is a GPS bug,
            // so we should just ignore this point if the speed is 0.
            print("Case 2: STATIONARY TO STATIONARY")
            
            #if !targetEnvironment(simulator)
            // Prevent buggy GPS signals in "jumping" the location.
            if (location.speed <= 0) {
              return
            }
            #endif
            
            ModelManager.shared.closeLocationEntry(lastLocationEntry!)
            currLocationEntry = ModelManager.shared.addLocationEntry(rawCoord, currMovementType)
            ModelManager.shared.assignPlaceIdToCurrentLocation(currLocationEntry!)
          }
        } else {
          if lastLocationEntry?.movement_type != MovementType.STATIONARY.rawValue {
            // Case 3: Move from non-stationary to stationary.
            // This means the user has likely moved from a non-stationary / commuting phase to a
            // stationary phase, i.e. the user has stopped moving and is now in a new location.
            print("Case 3: NON-STATIONARY TO STATIONARY")
            ModelManager.shared.closeLocationEntry(lastLocationEntry!)
            currLocationEntry = ModelManager.shared.addLocationEntry(rawCoord, currMovementType)
            ModelManager.shared.assignPlaceIdToCurrentLocation(currLocationEntry!)
          } else {
            // Case 4: Move from stationary to non-stationary.
            // This means the user has likely moved from a stationary phase to a non-stationary
            // (commuting) phase, i.e. the user has started moving.
            print("Case 4: STATIONARY to NON-STATIONARY")
            ModelManager.shared.closeLocationEntry(lastLocationEntry!)
            currLocationEntry = ModelManager.shared.addLocationEntry(rawCoord, currMovementType)
            ModelManager.shared.assignPlaceIdToCurrentLocation(currLocationEntry!)
          }
        }
      } else {
        currLocationEntry = lastLocationEntry!
      }
    } else {
      // If location entry is not found, then create a new one.
      print("Last location entry not found.")
      currLocationEntry = ModelManager.shared.addLocationEntry(rawCoord, currMovementType)
    }
    
    ModelManager.shared.appendRawCoord(currLocationEntry!, rawCoord)
    
  }
  
  // Callback functions for location manager.
  
  public func updateLocation(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let location:CLLocation = locations[0] as CLLocation
    updateLocation(location: location)
    
  }
  
}
