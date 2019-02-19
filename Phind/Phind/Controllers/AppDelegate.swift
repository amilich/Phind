//
//  AppDelegate.swift
//  Phind
//
//  Created by Andrew B. Milich on 1/26/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import GoogleMaps
import GooglePlaces
import UIKit
import CoreMotion
import RealmSwift
import JustLog

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  var locationManager = CLLocationManager()
  var motionActivityManager = CMMotionActivityManager()
  let placesClient = GMSPlacesClient()
  let realm = try! Realm()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // JustLog setup.
    let logger = Logger.shared
    logger.logFilename = "phind.log"
    logger.logstashHost = "listener.logz.io"
    logger.logstashPort = 5052
    logger.logzioToken = "WwwhuifBTWaSUATASxASOztzmHvXkRZJ"
    logger.setup()
    
    self.locationManager.requestAlwaysAuthorization()
    
    // Do any additional setup after loading the view.
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.distanceFilter = PhindLocationManager.DEFAULT_DISTANCE_FILTER
      locationManager.startUpdatingLocation()
    }
    
    GMSServices.provideAPIKey("AIzaSyAvGhM_3ABGXNwCdC2pfjnb_MbbBJWeJFU")
    GMSPlacesClient.provideAPIKey("AIzaSyAvGhM_3ABGXNwCdC2pfjnb_MbbBJWeJFU")

    // TODO: Remove this.
//    // Activate CoreMotion Activity Manager to check and update current movement type.
//    if CMMotionActivityManager.isActivityAvailable() {
//      motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (motion) in
//        PhindLocationManager.shared.updateMovementType(motion: motion!)
//      }
//    }
    
    #if targetEnvironment(simulator)
      print("Realm fileURL")
      print(Realm.Configuration.defaultConfiguration.fileURL ?? "<no url found>")
    #endif
  
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    forceSendLogs(application)
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // Resolve all the unresolved locations
    //        updateUnresolvedLocations()
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    forceSendLogs(application)
  }
  
  private func forceSendLogs(_ application: UIApplication) {
    
    var identifier = UIBackgroundTaskIdentifier(rawValue: 0)
    
    identifier = application.beginBackgroundTask(expirationHandler: {
      application.endBackgroundTask(identifier)
      identifier = UIBackgroundTaskIdentifier.invalid
    })
    
    Logger.shared.forceSend { completionHandler in
      application.endBackgroundTask(identifier)
      identifier = UIBackgroundTaskIdentifier.invalid
    }
  }
  
}

extension AppDelegate : CLLocationManagerDelegate{
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    PhindLocationManager.shared.updateLocation(manager, didUpdateLocations: locations)
  } 
  
}
