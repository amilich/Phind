//
//  PlaceDetails_PhotoTable.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

extension PlaceDetailsController {
  // Given a place ID, lookup the photos for the place and add one
  // to the UIImageview in the popup view detail.
  func loadPhotoForPlaceID(gms_id: String) {
    GMSPlacesClient.shared().lookUpPhotos(forPlaceID: gms_id) { (photoMetadata, error) -> Void in
      if let error = error {
        print("Error: \(error.localizedDescription)")
        print(error)
      } else {
        if photoMetadata?.results != nil {
          let numImages = (photoMetadata?.results)!.count
          // Add at most 9 items to the UICollectionView
          let numInGrid = min(numImages, 9)
          
          // Rescale the images based on how many there are
          let widthMinusBorder = UIScreen.main.bounds.width - Style.PHOTO_BORDER
          var photoWidth = widthMinusBorder / 3
          
          if numInGrid < 3 {
            photoWidth = widthMinusBorder
          } else if numInGrid < 6 {
            photoWidth = widthMinusBorder / 2
          }
          
          self.flowLayout.itemSize = CGSize(width: photoWidth, height: photoWidth)
          self.flowLayout.invalidateLayout()
          
          // Remove all old images
          self.placeImages.removeAll()
          for (index,metadata) in (photoMetadata?.results)!.enumerated() {
            // Once we hit max of all images, stop
            if index == numInGrid {
              break
            }
            GMSPlacesClient.shared().loadPlacePhoto(metadata, callback: { (photo, error) -> Void in
              if let error = error {
                print("Error: \(error.localizedDescription)")
                print(error)
              } else {
                if photo != nil {
                  self.placeImages.append(photo!)
                  self.photoCollection.reloadData()
                }
              }
            })
          }
        }
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.placeImages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
    
    let imageView = photoCell.placePhoto
    if indexPath.row < self.placeImages.count {
      // imageView.frame = photoCell.frame
      imageView.image = self.placeImages[indexPath.row].squared
      imageView.frame = photoCell.contentView.frame
      photoCell.addSubview(imageView)
    } else {
      imageView.image = nil
    }
    return photoCell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // TODO scale photo when tapped
    print("TODO scale photo to screen width")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
