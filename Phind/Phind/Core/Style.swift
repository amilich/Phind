//
//  Style.swift
//  Phind
//
//  Created by Kevin Chang on 3/3/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import UIKit

/// Class containing all style constants for Phind, including colors, offsets, and shadow parameters.
class Style {
  
  // Public constants.
  public static let PURPLE = UIColor(
    red: 84.0 / 255.0,
    green: 114.0 / 255.0,
    blue: 232.0 / 255.0,
    alpha: 1.0
  )
  public static let RED = UIColor(
    red:  232.0 / 255.0,
    green: 84.0 / 255.0,
    blue: 107.0 / 255.0,
    alpha: 1.0
  )
  public static let GREEN = UIColor(
    red:  84.0 / 255.0,
    green: 232.0 / 255.0,
    blue: 168.0 / 255.0,
    alpha: 1.0
  )
  
  public static let PRIMARY_COLOR = Style.PURPLE
  public static let SECONDARY_COLOR = Style.RED
  public static let TERTIARY_COLOR = Style.GREEN
  public static let BODY_COLOR = UIColor(
    red:  0,
    green: 0,
    blue: 0,
    alpha: 0.56
  )
  
  public static let SCREEN_MARGIN : CGFloat = 12.0
  public static let ELEMENT_MARGIN : CGFloat = 12.0
  public static let ELEMENT_PADDING : CGFloat = 16.0
  public static let CARD_CORNERS : CGFloat = 24.0
  public static let PHOTO_BORDER : CGFloat = 48.0
  public static let DETAILS_LABEL_OFFSET : CGFloat = 120.0
  public static let DETAILS_PHOTO_VIEW_HEIGHT : CGFloat = 200.0
  
  /// Width of the route drawn on the MapView
  public static let ROUTE_WIDTH: CGFloat = 4.0
  /// Color for the
  public static let ROUTE_COLOR: UIColor = Style.SECONDARY_COLOR
  
  // Icon parameters.
  public static let FAB_HEIGHT : CGFloat = 56.0
  public static let FAB_FONT_SIZE : CGFloat = 16.0
  public static let ICON_FONT = "FontAwesome5Free-Solid"
  
  // Header parameters.
  public static let HEADER_HEIGHT : CGFloat = 56.0
  
  // Text fields.
  public static let TEXT_FIELD_FONT = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
  
}

extension Style {
  
  /// Round the corners of the UIView.
  /// - parameter view: The UIView to add rounded corners to
  /// - parameter clip: Whether to clip the corners of the UIView (default false)
  public static func ApplyRoundedCorners(view: UIView, clip: Bool = false, radius: CGFloat = Style.CARD_CORNERS) {
    
    view.layer.cornerRadius = radius
    view.clipsToBounds = clip
    
  }
  
  /// Apply shadow to the boundary of a UIView.
  /// - parameter view: The UIView to add a shadow to
  public static func ApplyDropShadow(view: UIView) {
    
    view.layer.shadowOpacity = 0.16
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    view.layer.shadowRadius = 4.0
    
  }
  
  /// Set a UIView to the full width of the screen
  /// - parameter view: The UIView to set the width of
  /// - parameter positionWithMargin: Whether to set the frame to the screen margin position (default true).
  public static func SetFullWidth(view: UIView, positionWithMargin: Bool = true) {
    
    view.frame.size.width = UIScreen.main.bounds.width - Style.SCREEN_MARGIN * 2
    if (positionWithMargin) {
      view.frame.origin.x = Style.SCREEN_MARGIN
    }
    
  }
  
  public static func CreateFab(icon: String, backgroundColor: UIColor, iconColor: UIColor) -> UIButton {
    
    let fab = UIButton(frame: CGRect(x: 0, y: 0, width: Style.FAB_HEIGHT, height: Style.FAB_HEIGHT))
    fab.setTitle(icon, for: .normal)
    fab.titleLabel?.font =  UIFont(name: Style.ICON_FONT, size: Style.FAB_FONT_SIZE)
    fab.setTitleColor(iconColor, for: .normal)
    fab.backgroundColor = backgroundColor
    Style.ApplyDropShadow(view: fab)
    fab.layer.cornerRadius = Style.FAB_HEIGHT * 0.5
    
    return fab
    
  }
  
}
