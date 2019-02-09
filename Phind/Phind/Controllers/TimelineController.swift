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

class TimelineController: UIViewController {
  // Setup all the links to the UI.
  @IBOutlet weak var currentDateLabel: UILabel!
  
  override func viewWillAppear(_ animated: Bool) {
    
    // Setup all the UI elements to the proper dynamic values.
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd, yyyy"
    currentDateLabel.text = formatter.string(from: date)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //    // Do any additional setup after loading the view, typically from a nib.
    //    let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
    //    let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    //    view = mapView
    //
    //    // Creates a marker in the center of the map.
    //    let marker = GMSMarker()
    //    marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
    //    marker.title = "Sydney"
    //    marker.snippet = "Australia"
    //    marker.map = mapView
    
  }
  
}

