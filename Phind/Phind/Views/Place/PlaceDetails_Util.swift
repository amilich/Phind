//
//  util.swift
//  Phind
//
//  Created by Andrew B. Milich on 3/4/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit

/// The PhotoCell encapsulates a single photo used to display place details.
class PhotoCell: UICollectionViewCell {
  
  /// The placePhoto stores the image in the custom UICollectionViewCell.
  @IBOutlet var placePhoto: UIImageView!
  
  /// Initialize the cell with the necessary style parameters.
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    placePhoto.contentMode = .scaleAspectFill
    placePhoto.frame = self.contentView.frame
    placePhoto.center = CGPoint(x: self.contentView.bounds.size.width / 2, y: self.contentView.bounds.size.height / 2);
    
    self.contentView.addSubview(placePhoto)
    self.backgroundColor = .red
  }
  
  /// Used to encode and decode the place in the storyboard view.
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  /// Awake the cell component when it is needed for rendering.
  override func awakeFromNib() {
    super.awakeFromNib();
  }
}

/// Creates square version of UIImage. See https://stackoverflow.com/questions/44436980/crop-uiimage-to-center-square. We use this extension to crop the Google Place photos into squares.
extension UIImage {
  /// Determine if image is taller than it is wide.
  var isPortrait: Bool {
    return size.height > size.width
  }
  /// Determine if image is wider than it is tall.
  var isLandscape: Bool {
    return size.width > size.height
  }
  /// Minimum of width and height - used for square dimensions.
  var breadth: CGFloat {
    return min(size.width, size.height)
  }
  /// Convert breadth property into square CGSize.
  var breadthSize: CGSize {
    return CGSize(width: breadth, height: breadth)
  }
  /// Create rect using breadthSize square.
  var breadthRect: CGRect {
    return CGRect(origin: .zero, size: breadthSize)
  }
  /// Create and return a square cropped UIImage.
  var squared: UIImage? {
    UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
    defer { UIGraphicsEndImageContext() }
    guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
    UIImage(cgImage: cgImage).draw(in: breadthRect)
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
