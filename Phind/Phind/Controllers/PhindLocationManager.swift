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
import JustLog

/// Motion activites based on Apple definitions here: https://apple.co/2SlBGg2
public enum MovementType : String {
  case AUTOMOTIVE, CYCLING, WALKING, STATIONARY
  static let allTypes = [AUTOMOTIVE, CYCLING, WALKING, STATIONARY]
}

/// The PhindLocationManager is responsible for managing all recorded location updates from CoreMotion, including activity types and latitude/longitude updates.
public class PhindLocationManager : NSObject, CLLocationManagerDelegate {
  
  // Public static fields.
  
  /// Singleton declaration.
  public static let shared = PhindLocationManager()
  // TODO: Change this back to 15.0m when done debugging.
  /// Distance filter for ignoring location updates.
  public static let DEFAULT_DISTANCE_FILTER : CLLocationDistance = 15.0
  /// Minimum threshold for a new location to register as a new LocationEntry (in meters).
  public static let NOTABLE_DISTANCE_THRESHOLD = 50.0
  
  // Private constants.
  /// The window for how far back we go to check CoreMotion activities.
  private let ACTIVITY_TRACKING_WINDOW = 180
  
  // Public fields.
  /// The current - i.e. last received - movement type.
  public private(set) var currMovementType = MovementType.STATIONARY
  
  // Private fields.
  private var locationManager = AppDelegate().locationManager
  private var motionActivityManager = AppDelegate().motionActivityManager
  private var realm = AppDelegate().realm
  
  
  /// Add logging message to default constructor.
  override init() {
      super.init()
      Logger.shared.debug("PhindLocationManager has been initialized.")
  }
  
  /// Update movement type based on CMMotionActivity passed in from AppDelegate.
  /// - parameter motion: Object storing the current movement type.
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
        Logger.shared.verbose("Movement type switched to: \(currMovementType)")
      }
    
  }
  
  /// Get most likely movement type from a certain time period.
  /// - parameter from: Start time to search for motion.
  /// - parameter to: End time to search for motion.
  public func updateMovementType(from: Date, to: Date) {
    
      Logger.shared.debug("Begin updating movement type...")
    
      // TODO: There must be a cleaner way to do this.
      var movementTypeCounts: [MovementType:Int] = [
        MovementType.STATIONARY : 0,
        MovementType.WALKING    : 0,
        MovementType.CYCLING    : 0,
        MovementType.AUTOMOTIVE : 0
      ]
    
      let semaphore = DispatchSemaphore(value: 0)
      motionActivityManager.queryActivityStarting(from: from, to: to, to: OperationQueue()) { activities, error in
        Logger.shared.verbose("Activities: \(activities)")
        if activities != nil {
          for activity in activities! {
            // Only examine activity entries that are "medium" or "high" confidence.
            if (activity.confidence == CMMotionActivityConfidence.low) { continue }
          
            if activity.walking {
                movementTypeCounts[MovementType.WALKING]! += 1
            } else if activity.cycling {
                movementTypeCounts[MovementType.CYCLING]! += 1
            } else if activity.automotive {
                movementTypeCounts[MovementType.AUTOMOTIVE]! += 1
            } else {
                movementTypeCounts[MovementType.STATIONARY]! += 1
            }
          }
        
          // Check to find the most common type of movement amongst the activity entries
          // returned by the CoreMotion API.
          var cur_max = -1
          var tmpMovementType = self.currMovementType
          for movementType in MovementType.allTypes {
            if movementTypeCounts[movementType]! > cur_max {
              cur_max = movementTypeCounts[movementType]!
              tmpMovementType = movementType
            }
          }
        
          Logger.shared.verbose("Movement type: \(self.currMovementType) to \(tmpMovementType)")
          self.currMovementType = tmpMovementType
        }
      
        semaphore.signal()
      }
      _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    
  }
  
  /// Update location entries based on CLLocation. If location data indicates new location, then close the latest LocationEntry by adding a departure time and create a new LocationEntry. In all cases, add in a new rawCoord entry. See extensive inline documentation.
  /// - parameter location: Location used to update the PhindLocationManager internal data.
  private func updateLocation(location: CLLocation) {
  
    let rawCoord = ModelManager.shared.addRawCoord(location)
  
    // Check latest location entry in realm objects.
    var lastLocationEntry = ModelManager.shared.getMostRecentLocationEntry()
    var currLocationEntry : LocationEntry? = lastLocationEntry
  
    // Check to see lastLocationEntry is from today. If not, then close it and
    // create a new one for the current date.
    if lastLocationEntry != nil && !Util.IsDateToday(date: lastLocationEntry!.start as Date) {
      ModelManager.shared.closeLocationEntry(lastLocationEntry!)
      // TODO: Is raw_coords proper sorted?
      let lastLocationEntryRawCoord = lastLocationEntry?.raw_coordinates.last
      lastLocationEntry = ModelManager.shared.addLocationEntry(
        lastLocationEntryRawCoord!,
        MovementType(rawValue: (lastLocationEntry?.movement_type)!)!,
        Util.GetLocalizedDayStart(date: Date())
      )
      currLocationEntry = lastLocationEntry
    }
  
    // Get current movement type from CoreMotion.
    let motionActivityFrom = lastLocationEntry != nil ?
      lastLocationEntry!.start as Date :
      Calendar.current.date(
          byAdding: .second,
          value: -ACTIVITY_TRACKING_WINDOW,
          to: Date()
        )
    updateMovementType(from: motionActivityFrom!, to: Date())
  
    // Update and create new LocationEntries depending on whether or not
    // lastLocationEntry exists and the distance between last location (if it exists)
    // and the current location.
    if (lastLocationEntry != nil) {
      Logger.shared.verbose("Last location movement type: \(lastLocationEntry?.movement_type ?? "")")
    
      // If last location exists, check how far the current location is from it.
      let lastLocation = CLLocation(
        latitude: lastLocationEntry?.latitude ?? -1.0,
        longitude: lastLocationEntry?.longitude ?? -1.0
      )
      let distanceFromLastLocation = lastLocation.distance(from: location)
      Logger.shared.verbose("Distance from last location: \(distanceFromLastLocation)")
    
      // If the distance between the location of the most recent LocationEntry and the current
      // coordinates is greater than NOTABLE_DISTANCE_THRESHOLD, then need to evaluate a few cases
      // to determine what is happening.
      if (distanceFromLastLocation >= PhindLocationManager.NOTABLE_DISTANCE_THRESHOLD) {
        if lastLocationEntry?.movement_type == currMovementType.rawValue {
            if currMovementType != MovementType.STATIONARY {
              // Case 1: Move from non-stationary to non-stationary.
              // This means the user was moving and is still moving, and as such, we will simply append
              // the raw coord to the last location entry.
              Logger.shared.verbose("Case 1: NON-STATIONARY TO NON-STATIONARY")
              currLocationEntry = lastLocationEntry!
            } else {
              // Case 2: Move from stationary to stationary.
              // This means the user has hopped from one stationary location to another, with a distance
              // > NOTABLE_DISTANCE_THRESHOLD in between the two. This is unlikely to happen, since
              // there would likely be some mode of movement in between. It is likely this is a GPS bug,
              // so we should just ignore this point if the speed is 0.
              Logger.shared.verbose("Case 2: STATIONARY TO STATIONARY")
            
              // Prevent buggy GPS signals in "jumping" the location.
              if (location.speed <= 0) {
                  Logger.shared.verbose("Negative speed recorded.")
                  // TODO
                  // return
              }
            
              ModelManager.shared.closeLocationEntry(lastLocationEntry!)
              currLocationEntry = ModelManager.shared.addLocationEntry(rawCoord, currMovementType)
              ModelManager.shared.assignPlaceIdToLocation(currLocationEntry!)
            }
        } else {
          if lastLocationEntry?.movement_type != MovementType.STATIONARY.rawValue {
            // Case 3: Move from non-stationary to stationary.
            // This means the user has likely moved from a non-stationary / commuting phase to a
            // stationary phase, i.e. the user has stopped moving and is now in a new location.
            Logger.shared.verbose("Case 3: NON-STATIONARY TO STATIONARY/NON-STATIONARY")
            ModelManager.shared.closeLocationEntry(lastLocationEntry!)
            currLocationEntry = ModelManager.shared.addLocationEntry(rawCoord, currMovementType)
            ModelManager.shared.assignPlaceIdToLocation(currLocationEntry!)
          } else {
            // Case 4: Move from stationary to non-stationary.
            // This means the user has likely moved from a stationary phase to a non-stationary
            // (commuting) phase, i.e. the user has started moving.
            Logger.shared.verbose("Case 4: STATIONARY to NON-STATIONARY")
            ModelManager.shared.closeLocationEntry(lastLocationEntry!)
            currLocationEntry = ModelManager.shared.addLocationEntry(rawCoord, currMovementType)
            ModelManager.shared.assignPlaceIdToLocation(currLocationEntry!)
          }
        }
      } else {
        currLocationEntry = lastLocationEntry!
      }
    } else {
      // If location entry is not found, then create a new one.
      Logger.shared.verbose("Last location entry not found.")
      currLocationEntry = ModelManager.shared.addLocationEntry(rawCoord, currMovementType)
      ModelManager.shared.assignPlaceIdToLocation(currLocationEntry!)
    }
  
    ModelManager.shared.appendRawCoord(currLocationEntry!, rawCoord)
    
  }
  
  /// Callback function for location manager.
  public func updateLocation(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    Logger.shared.verbose("Locations \(locations)")
    let location:CLLocation = locations[0] as CLLocation
    updateLocation(location: location)
    
  }
}
