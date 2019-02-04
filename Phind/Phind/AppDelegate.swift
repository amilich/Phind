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
import RealmSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    
    var locationManager = CLLocationManager()
    let placesClient = GMSPlacesClient()
    let realm = try! Realm()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.locationManager.requestAlwaysAuthorization()
        
        // Do any additional setup after loading the view.
        // https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
        if CLLocationManager.locationServicesEnabled() {
          locationManager.delegate = self
          locationManager.desiredAccuracy = kCLLocationAccuracyBest
          locationManager.startUpdatingLocation() // TODO is this the right place
        }
        
        print("HEYYY")
        
        GMSServices.provideAPIKey("AIzaSyAvGhM_3ABGXNwCdC2pfjnb_MbbBJWeJFU")
        GMSPlacesClient.provideAPIKey("AIzaSyAvGhM_3ABGXNwCdC2pfjnb_MbbBJWeJFU")

        self.locationManager.requestAlwaysAuthorization()

        // Do any additional setup after loading the view.
        // https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation() // TODO is this the right place
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
    }
    
}

extension AppDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Hello")
        // create CLLocation from the coordinates of CLVisit
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let cur_loc = RealmLocation()
        cur_loc.latitude = NSNumber(value: userLocation.coordinate.latitude) // Constructor?
        cur_loc.longitude = NSNumber(value: userLocation.coordinate.longitude)
        
        print("Location lat = \(userLocation.coordinate.latitude)")
        print("Location lon = \(userLocation.coordinate.longitude)")
        
        try! realm.write {
            realm.add(cur_loc)
            print("Wrote to realm")
            
        }
        
    }
}
