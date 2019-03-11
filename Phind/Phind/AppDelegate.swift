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

/// The AppDelegateClass provides the programmatic entry point to Phind. It manages app launch by setting up access methods to our database, APIs, location manager, and logging tool.
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  /// The locationManager delivers location updates from coreMotion to Phind
  var locationManager = CLLocationManager()
  /// The motionActivityManager provides additional movement information, such as the movement type
  var motionActivityManager = CMMotionActivityManager()
  /// The AppDelegate placesClient is used to initialize access to the Google Maps and Places APIs
  let placesClient = GMSPlacesClient()
  /// This access to our Realm database is used to print the location of the current database file
  let realm = try! Realm()
  /// Shared URL session later used by controllers to query APIs
  let sharedUrlSession = URLSession.shared
  
  /// Initialize logging, location manager, and Google APIs for use by other controllers in the app.
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Setup JustLog.
    let logger = Logger.shared
    logger.logFilename = "phind.log"
    logger.logstashHost = "listener.logz.io"
    logger.logstashPort = 5052
    logger.logzioToken = Credentials.LOGZ_IO_TOKEN
    logger.setup()
    
    // Setup location manager and location updates.
    self.locationManager.requestAlwaysAuthorization()
    if CLLocationManager.significantLocationChangeMonitoringAvailable() {
      locationManager.delegate = self
      locationManager.startUpdatingLocation()
      locationManager.startMonitoringSignificantLocationChanges()
    } else {
      Logger.shared.error("Significant location change monitoring not available.")
    }
    
    #if targetEnvironment(simulator)
      print("Realm fileURL")
      print(Realm.Configuration.defaultConfiguration.fileURL ?? "<no url found>")
    #endif

    // Setup Google Maps keys.
    GMSServices.provideAPIKey(Credentials.GMS_KEY)
    GMSPlacesClient.provideAPIKey(Credentials.GMS_KEY)
    
    // Setup colors and styling.
    UITabBar.appearance().tintColor = Style.PRIMARY_COLOR
    
    return true
  }
  
  /// Application no longer active. Not currently used.
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  /// Application has entered background. Currently only sends collected logging data.
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    forceSendLogs(application)
  }
  
  /// Called when user puts Phind back in foreground. Not currently used.
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  /// Called when the application becomes active after a period of inactivity. Not currently used.
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  /// When application will be closed, send logs.
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    forceSendLogs(application)
  }
  
  /// Using our logging tool, upload the collected logs in a background task.
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
  
  /// Phind notification handler.
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
    
    Logger.shared.debug("Entire message \(userInfo)")
    completionHandler(UIBackgroundFetchResult.newData)
  }
  
}

/// Extend AppDelegate to receive location updates.
extension AppDelegate : CLLocationManagerDelegate {
  
  /// Location update function forwards the location update to the PhindLocationManager class.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    Logger.shared.verbose("Location manager delegate called.")
    PhindLocationManager.shared.updateLocation(manager, didUpdateLocations: locations)
  } 
  
}

