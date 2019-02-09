//
//  TimelineController.swift
//  Phind
//
//  Created by Andrew B. Milich on 1/26/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import RealmSwift

class TimelineController: UIViewController {
  // Constants.
  let MAP_SPAN_LAT = 10000
  let MAP_SPAN_LONG = 10000
  
  // Setup all the links to the UI.
  @IBOutlet weak var currentDateLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  
  // TODO: Should this be moved into a function?
  let realm = try! Realm()
  
  // viewWillAppear and viewDidLoad all follow the cycle delineated
  // here: https://apple.co/2DqFnH6
  override func viewWillAppear(_ animated: Bool) {
    
    // Setup all the UI elements to the proper dynamic values.
    
    // Update current date label at the top of the screen.
    // TODO(kevin): Update this to display date as Feb 9, 2019,
    //              instead of Feb 09, 2019.
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd, yyyy"
    currentDateLabel.text = formatter.string(from: date)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Update map view to center around user's current location.
    let userLocations = realm.objects(RealmLocation.self);
    if (userLocations.count > 0) {
      let userLocation = userLocations.last!
      print(userLocation.latitude)
      print(userLocation.longitude)
      
      let coordinateRegion = MKCoordinateRegion.init(
        center: CLLocationCoordinate2D(
          latitude: CLLocationDegrees(userLocation.latitude),
          longitude: CLLocationDegrees(userLocation.longitude)),
        latitudinalMeters: MAP_SPAN_LAT,
        longitudinalMeters: MAP_SPAN_LONG)
      mapView.setRegion(coordinateRegion, animated: true)
    }
    
  }
  
}

