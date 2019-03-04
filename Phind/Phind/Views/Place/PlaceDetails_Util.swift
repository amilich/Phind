//
//  util.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit

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
