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
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let realm = try! Realm()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyAvGhM_3ABGXNwCdC2pfjnb_MbbBJWeJFU")
        GMSPlacesClient.provideAPIKey("AIzaSyAvGhM_3ABGXNwCdC2pfjnb_MbbBJWeJFU")
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
    
    func getPlaceIdForLocation(_ loc: RealmLocation) {
        let coordinates = CLLocationCoordinate2DMake(Double(loc.latitude), Double(loc.longitude))
        // make request to google API using latitude and longitude to get place id and return
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinates) {response , error in
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]
                print("Address: \(lines)")
                print("Response: \(response)")
            }
        }
        
    }
    
    func updateUnresolvedLocations() {
        let unresolved_locations = realm.objects(RealmLocation.self).filter("place_id = -1.0")
        print("Starting to resolve locations");
        for loc in unresolved_locations {
            print("Unresolved loc: \(loc.latitude),\(loc.longitude)")
            getPlaceIdForLocation(loc)
            // Get place ID for the location using latitude/longitude
            //            print("Unresolved loc: \(loc.latitude),\(loc.longitude)")
            //            let new_place_id = 1
            //            let old_places = realm.objects(RealmPlace.self).filter("place_id = \(new_place_id)")
            //            if old_places.endIndex == 0 { // TODO length??
            //                print("\tNo place found")
            //            } else {
            //                print("\tFound place ID = \(new_place_id)")
            //            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Resolve all the unresolved locations
        updateUnresolvedLocations()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

