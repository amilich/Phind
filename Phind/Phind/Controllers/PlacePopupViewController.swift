//
//  PlacePopupViewController.swift
//  Phind
//
//  Created by Andrew B. Milich on 2/17/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import GoogleMaps
import GooglePlaces

class PlacePopupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  // Data storage elements
  public var place = Place()
  var placeImages: [UIImage] = []

  // UI components
  let label = UILabel()
  let addressLabel = UILabel()
  let backButton = UIButton()
  let editButton = UIButton()
  let flowLayout = UICollectionViewFlowLayout()
  var photoCollection : UICollectionView
  
  // UI design constants
  let photoBorder = 30.0 as CGFloat
  
  init() {
    // self.photoCollection = UICollectionView(frame: CGRect(x: 0, y: 130, width: self.view.frame.width, height: 250), collectionViewLayout: flowLayout)
    self.photoCollection = UICollectionView(frame: CGRect(x: 0, y: 130, width: 300, height: 250), collectionViewLayout: flowLayout)
    
    super.init(nibName: nil, bundle: nil)
    
    self.definesPresentationContext = true
    
    let width = UIScreen.main.bounds.width
    
    // let labelBorder = CGFloat(10)
    // let labelX = labelBorder / 2
    // label.frame = CGRect(x: labelX, y: 0, width: width, height: 160)
    label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
    label.textAlignment = .center
    label.font = label.font.withSize(25)
    label.adjustsFontSizeToFitWidth = true
    // label.sizeToFit()
    // label.lineBreakMode = .byWordWrapping
    // label.numberOfLines = 0

    addressLabel.frame = CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 80)
    addressLabel.textAlignment = .center
    addressLabel.font = label.font.withSize(15)
    
    flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    let photoSize = (width - photoBorder) / 3
    flowLayout.itemSize = CGSize(width: photoSize, height: photoSize)
    
    photoCollection.dataSource = self
    photoCollection.delegate = self
    photoCollection.backgroundColor = .white
    photoCollection.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
    
    backButton.frame = CGRect(x: 10, y: 15, width: 50, height: 50)
    backButton.setImage(UIImage(named: "back.png"), for: .normal)
    backButton.setTitle("Back", for: .normal)
    backButton.addTarget(self, action: #selector(self.backPressed(_:)), for: .touchUpInside)
    
    editButton.frame = CGRect(x: width - 60, y: 15, width: 50, height: 50)
    editButton.setTitle("Edit", for: .normal)
    editButton.backgroundColor = .red
    editButton.addTarget(self, action: #selector(self.editPressed(_:)), for: .touchUpInside)
    
    self.view.addSubview(label)
    self.view.addSubview(addressLabel)
    self.view.addSubview(backButton)
    self.view.addSubview(editButton)
    self.view.addSubview(photoCollection)
    self.view.backgroundColor = .white
    self.view.isHidden = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Initialize the button and text elements inside the
  // place popup view.
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // TODO(Andrew) Move into init
    self.photoCollection.frame = CGRect(x: 0, y: 130, width: self.view.frame.width, height: 250)
  }
  
  @objc func backPressed(_ sender: UIButton!) {
    self.view.isHidden = !self.view.isHidden
  }
  
  @objc func editPressed(_ sender: UIButton!) {
    print("Edit")
  }
  
  // Called to set the place to be displayed on the popup view.
  public func setPlace(place: Place) {
    self.place = place;
    self.label.text = self.place.name
    self.addressLabel.text = self.place.address
    // Get rid of the previous image
    self.placeImages.removeAll()
    self.photoCollection.reloadData()
    // Now load a new image
    self.loadPhotoForPlaceID(gms_id: place.gms_id)
  }
  
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
          let widthMinusBorder = UIScreen.main.bounds.width - self.photoBorder
          var photoWidth = widthMinusBorder / 3
          print(photoWidth)
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
                print("Setting photo!")
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

class PhotoCell: UICollectionViewCell {

  var placePhoto : UIImageView

  override init(frame: CGRect) {
    placePhoto = UIImageView()
    
    super.init(frame: frame)
    
    placePhoto.contentMode = .scaleAspectFill
    placePhoto.frame = self.contentView.frame
    placePhoto.center = CGPoint(x: self.contentView.bounds.size.width / 2, y: self.contentView.bounds.size.height / 2);

    self.contentView.addSubview(placePhoto)
    self.backgroundColor = .red
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func awakeFromNib() {
    super.awakeFromNib();
  }
}

// Creates square version of UIImage
// See https://stackoverflow.com/questions/44436980/crop-uiimage-to-center-square
// Used for place photos
extension UIImage {
  var isPortrait: Bool {
    return size.height > size.width
  }
  var isLandscape: Bool {
    return size.width > size.height
  }
  var breadth: CGFloat {
    return min(size.width, size.height)
  }
  var breadthSize: CGSize {
    return CGSize(width: breadth, height: breadth)
  }
  var breadthRect: CGRect {
    return CGRect(origin: .zero, size: breadthSize)
  }
  var squared: UIImage? {
    UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
    defer { UIGraphicsEndImageContext() }
    guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
    UIImage(cgImage: cgImage).draw(in: breadthRect)
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
