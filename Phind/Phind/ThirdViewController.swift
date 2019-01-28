//
//  ThirdViewController.swift
//  Phind
//
//  Created by Andrew B. Milich on 1/27/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ThirdViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()
        
        // Do any additional setup after loading the view.
        // https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation() // TODO is this the right place
        }
    }
    
    // http://swiftdeveloperblog.com/code-examples/determine-users-current-location-example-in-swift/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location
        // manager.stopUpdatingLocation()
        
        print("Location lat = \(userLocation.coordinate.latitude)")
        print("Location lon = \(userLocation.coordinate.longitude)")
        // https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
        let coordinateRegion = MKCoordinateRegion.init(center: userLocation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
        mapView.setRegion(coordinateRegion, animated: true)
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
