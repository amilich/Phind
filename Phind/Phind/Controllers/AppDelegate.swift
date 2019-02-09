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
    
    // Anna
    GMSServices.provideAPIKey("AIzaSyAvGhM_3ABGXNwCdC2pfjnb_MbbBJWeJFU")
    GMSPlacesClient.provideAPIKey("AIzaSyAvGhM_3ABGXNwCdC2pfjnb_MbbBJWeJFU")
    // Andrew
    //        GMSServices.provideAPIKey("AIzaSyCKmapjQc3SU99_Ik-mTNbQh3FgPJGUWN0")
    //        GMSPlacesClient.provideAPIKey("AIzaSyCKmapjQc3SU99_Ik-mTNbQh3FgPJGUWN0")
    
    self.locationManager.requestAlwaysAuthorization()
    
    // Do any additional setup after loading the view.
    // https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.startUpdatingLocation() // TODO is this the right place
    }
    
    print(Realm.Configuration.defaultConfiguration.fileURL!)
    
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
    cur_loc.latitude = userLocation.coordinate.latitude // Constructor?
    cur_loc.longitude = userLocation.coordinate.longitude
    
    print("Location lat = \(userLocation.coordinate.latitude)")
    print("Location lon = \(userLocation.coordinate.longitude)")
    
    let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
      UInt(GMSPlaceField.placeID.rawValue))!
    
    GMSPlacesClient.shared().findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
      (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
      if let error = error {
        print("An error occurred: \(error.localizedDescription)")
        print(error);
        try! self.realm.write {
          self.realm.add(cur_loc)
          print("Wrote to realm without place IDs")
        }
        return
      }
      if let placeLikelihoodList = placeLikelihoodList {
        for likelihood in placeLikelihoodList {
          let place = likelihood.place
          print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
          print("Current PlaceID \(String(describing: place.placeID))")
          
          let likely_place = RealmLikelyPlace()
          likely_place.likelihood = likelihood.likelihood
          likely_place.place_id = place.placeID ?? "" // TODO need default value
          likely_place.name = place.name ?? ""
          likely_place.address = place.formattedAddress ?? ""
          cur_loc.likelyPlaces.append(likely_place);
          
          //                    if (place.placeID != nil) {
          //                        let placeID = place.placeID
          //                        let predicate = NSPredicate(format: "place_id = %@", placeID ?? "")
          //                        let old_places = self.realm.objects(RealmPlace.self).filter(predicate)
          //                        if old_places.endIndex == 0 { // TODO length??
          //                            print("\tNo place found")
          //                        } else {
          //                            print("\tFound place")
          //                        }
          //                        break
          //                    }
        }
        try! self.realm.write {
          self.realm.add(cur_loc)
          print("Wrote to realm with place IDs")
        }
      }
    })
  }
}
