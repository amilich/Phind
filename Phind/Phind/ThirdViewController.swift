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
import CoreLocation

class ThirdViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let realm = try! Realm()

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
        // https://stackoverflow.com/questions/47256304/creating-a-google-map-in-ios-that-doesnt-fit-the-whole-screen
        mapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        let cur_loc = RealmLocation()
        try! realm.write {
            realm.add(cur_loc)
            print("Wrote to realm")
        }
    }
    
    // Partial snippet credit
    // http://swiftdeveloperblog.com/code-examples/determine-users-current-location-example-in-swift/
    // https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        let cur_loc = RealmLocation()
        cur_loc.latitude = NSNumber(value: userLocation.coordinate.latitude) // Constructor?
        cur_loc.longitude = NSNumber(value: userLocation.coordinate.longitude)
        
        try! realm.write {
            realm.add(cur_loc)
            print("Wrote to realm")
        }
        
        // manager.stopUpdatingLocation() to stop getting location updates
        
        print("Location lat = \(userLocation.coordinate.latitude)")
        print("Location lon = \(userLocation.coordinate.longitude)")
        
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
