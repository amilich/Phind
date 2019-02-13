//
//  MapViewFitExtension.swift
//  Phind
//
//  Created by Andrew B. Milich on 2/12/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import MapKit

// Taking this extension to fit our map around annotations
// https://stackoverflow.com/questions/39747957/mapview-to-show-all-annotations-and-zoom-in-as-much-as-possible-of-the-map?rq=1
extension MKMapView {

  /// When we call this function, we have already added the annotations to the map, and just want all of them to be displayed.
  func fitAll() {
    var zoomRect            = MKMapRect.null;
    for annotation in annotations {
      let annotationPoint = MKMapPoint(annotation.coordinate)
      let pointRect       = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01);
      zoomRect            = zoomRect.union(pointRect);
    }
    setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
  }
  
  /// We call this function and give it the annotations we want added to the map. we display the annotations if necessary
  func fitAll(in annotations: [MKAnnotation], andShow show: Bool) {
    var zoomRect:MKMapRect  = MKMapRect.null
    
    for annotation in annotations {
      let aPoint          = MKMapPoint(annotation.coordinate)
      let rect            = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)
      
      if zoomRect.isNull {
        zoomRect = rect
      } else {
        zoomRect = zoomRect.union(rect)
      }
    }
    if(show) {
      addAnnotations(annotations)
    }
    setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
  }
  
}
