//
//  MainView_Map.swift
//  Phind
//
//  All logic as it pertains to the main view map goes here.
//
//  Created by Kevin Chang on 3/3/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import JustLog

class MapPin: NSObject, MKAnnotation {
  dynamic var coordinate: CLLocationCoordinate2D
  dynamic var title: String?
  dynamic var subtitle: String?
  
  init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
    self.coordinate = coordinate
    self.title = title
    self.subtitle = subtitle
    
    super.init()
  }
}

extension MainViewController :  MKMapViewDelegate {
  
  // Add locations from today to map and timeline
  internal func reloadMapView() {
    
    // Reset mapkit view.
    mapView.removeAnnotations(mapView.annotations)
    mapView.removeOverlays(mapView.overlays)
    
    // Iterate through each LocationEntry to draw pins and routes, as well
    // as generate cards for the timeline.
    var lastCoord: CLLocationCoordinate2D?
    for locationEntry in self.locationEntries {
      if locationEntry.movement_type == MovementType.STATIONARY.rawValue {
        drawPin(&lastCoord, locationEntry)
      } else {
        // TODO: Add location entries to timeline even if they are not stationary.
        drawRoute(&lastCoord, locationEntry)
      }
    }
    
    // Recenter and resize map.
    if self.mapView.annotations.count > 0 { self.mapView!.fitAll() }
    
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    
    // Return an `MKPolylineRenderer` for the `MKPolyline` in the `MKMapViewDelegate`s method
    if let polyline = overlay as? MKPolyline {
      let mapLineRenderer = MKPolylineRenderer(polyline: polyline)
      mapLineRenderer.strokeColor = ROUTE_COLOR
      mapLineRenderer.lineWidth = ROUTE_WIDTH
      return mapLineRenderer
    }
    fatalError("Something wrong...")
    
  }
  
  func drawPin(_ lastCoord: inout CLLocationCoordinate2D?, _ locationEntry: LocationEntry) {
    
    // Add a pin for each stationary location on the map.
    formatter.dateFormat = "h:mm a"

    var subtitle = formatter.string(from: locationEntry.start as Date)
    if locationEntry.end != nil {
      subtitle += " to " + formatter.string(from: locationEntry.end! as Date)
    } else {
      subtitle += " to now"
    }
    
    let currCoord = CLLocationCoordinate2D(
      latitude: locationEntry.latitude,
      longitude: locationEntry.longitude
    )
    
    // If lastCoord exists before pin is drawn, draw a line from the
    // lastCoord to this point.
    if lastCoord != nil {
      let routeCoords: [CLLocationCoordinate2D] = [lastCoord!, currCoord]
      let routeLine = MKPolyline(coordinates: routeCoords, count: routeCoords.count)
      mapView.addOverlay(routeLine)
    }
    
    // Update lastCoord and draw pin.
    lastCoord = currCoord
    let annotation: MapPin = MapPin(
      coordinate: currCoord,
      subtitle: subtitle
    )
    mapView.addAnnotation(annotation)
    
  }
  
  func drawRoute(_ lastCoord: inout CLLocationCoordinate2D?, _ locationEntry: LocationEntry) {
    
    // Ensure that coordinatse are in proper order, by timestamp.
    // TODO: Do we need to sort this?
    var raw_coordinates = locationEntry.raw_coordinates
    raw_coordinates.sort(
      by: { $0.timestamp.compare($1.timestamp as Date) == ComparisonResult.orderedAscending }
    )
    
    // Draw a route for commuting component.
    var routeCoords: [CLLocationCoordinate2D] = []
    if (lastCoord != nil) { routeCoords.append(lastCoord!) }
    for rawCoord in raw_coordinates {
      let coord = CLLocationCoordinate2DMake(rawCoord.latitude, rawCoord.longitude)
      routeCoords.append(coord)
    }
    lastCoord = routeCoords.last
    
    let routeLine = MKPolyline(coordinates: routeCoords, count: routeCoords.count)
    mapView.addOverlay(routeLine)
    
  }
  
}
