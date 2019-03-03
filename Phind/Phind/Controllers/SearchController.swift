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
import CardParts


class SearchViewController: CardsViewController, MKMapViewDelegate {
  
  let cards: [CardController] = [TimelineCardController()]
  var window: UIWindow?
  var mapView: MKMapView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    loadCards(cards: cards)
    
    self.mapView = MKMapView( frame: CGRect(x: 0, y: 20, width: (self.window?.frame.width)!, height: 300) )
    self.view.addSubview(self.mapView!)
    
  }
  
}
