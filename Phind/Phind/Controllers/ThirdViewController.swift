//
//  ThirdViewController.swift
//  Phind
//
//  Created by Andrew B. Milich on 1/27/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import GoogleMaps
import GooglePlaces
import CoreLocation
import TransitionableTab

class ThirdViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  
  let placesClient = GMSPlacesClient()
  let realm = try! Realm()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // https://stackoverflow.com/questions/47256304/creating-a-google-map-in-ios-that-doesnt-fit-the-whole-screen
    //  mapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)

    //  let userLocations = realm.objects(RealmLocation.self);
    //  if (userLocations.count > 0) {
    //    let userLocation =  userLocations.last!
    //    print(userLocation.latitude)
    //    print(userLocation.longitude)

    //    let coordinateRegion = MKCoordinateRegion.init(
    //      center: CLLocationCoordinate2D(
    //        latitude: CLLocationDegrees(userLocation.latitude),
    //        longitude: CLLocationDegrees(userLocation.longitude)),
    //      latitudinalMeters: 100000,
    //      longitudinalMeters: 100000)
    //    mapView.setRegion(coordinateRegion, animated: true)
    //  }
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
  
}
