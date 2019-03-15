//
//  Style.swift
//  Phind
//
//  Created by Kevin Chang on 3/3/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import UIKit

enum Alignment {
  case LEFT, CENTER, RIGHT
}

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
  
  /// Height of the search view cells
  public static let SEARCH_VIEW_CELL_HEIGHT : CGFloat = 80.0
  /// Margin between distinct elements
  public static let ELEMENT_MARGIN : CGFloat = 12.0
  /// Padding within an element
  public static let ELEMENT_PADDING : CGFloat = 16.0
  /// Screen margin around UI card components
  public static let SCREEN_MARGIN : CGFloat = 12
  /// Corner radius for cards
  public static let CARD_CORNERS : CGFloat = 24.0
  /// Border size for photo collection view
  public static let PHOTO_BORDER : CGFloat = 48.0
  /// Offset for the details label from top on place details plage
  public static let DETAILS_LABEL_OFFSET : CGFloat = 120.0
  /// Photo domensions for photo collection in place details view
  public static let DETAILS_PHOTO_VIEW_HEIGHT : CGFloat = 200.0
  
  /// Latitudinal span for MapView
  public static let MAP_SPAN_LAT = 1000.0
  /// Longitudinal span for MapView
  public static let MAP_SPAN_LONG = 1000.0
  
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
  public static let TEXT_FIELD_FONT = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
  
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
  public static func SetFullWidth(view: UIView) {
    
    view.frame.size.width = UIScreen.main.bounds.width - Style.SCREEN_MARGIN * 2
    view.frame.origin.x = Style.SCREEN_MARGIN
    
  }
  
  public static func SetPartialWidth(view: UIView, offset: CGFloat) {
    
    view.frame.size.width = UIScreen.main.bounds.width - Style.SCREEN_MARGIN * 2 - Style.ELEMENT_MARGIN - offset
    
  }
  
  
  public static func SetAlignment(view: UIView, offsetX: CGFloat = 0, offsetY: CGFloat = 0, align: Alignment) {
    
    switch align {
    case Alignment.LEFT:
      view.frame.origin.x = Style.SCREEN_MARGIN
    default:
      view.frame.origin.x = UIScreen.main.bounds.width - view.frame.size.width - Style.SCREEN_MARGIN
    }
    
    view.frame.origin.y = UIApplication.shared.windows[0].safeAreaInsets.top + offsetY
    
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
  
  public static func SetupTextField(textField: UITextField) {
    
    textField.font = Style.TEXT_FIELD_FONT
    textField.borderStyle = UITextField.BorderStyle.none
    textField.autocorrectionType = UITextAutocorrectionType.no
    textField.keyboardType = UIKeyboardType.default
    textField.returnKeyType = UIReturnKeyType.done
    textField.clearButtonMode = UITextField.ViewMode.whileEditing
    textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
    
  }
  
  public static func SetupFullScreenView(_ view: UIView) {
    
    view.frame.origin.x = 0
    view.frame.origin.y = 0
    view.frame.size.width = UIScreen.main.bounds.width
    view.frame.size.height = UIScreen.main.bounds.height
    
  }
  
  public static func SetSize(view: UIView,
                             offsetTop: CGFloat = 0, offsetBottom: CGFloat = 0,
                             offsetLeft: CGFloat = 0, offsetRight: CGFloat = 0) {
    
    view.frame.size.width = UIScreen.main.bounds.width - offsetLeft - offsetRight - Style.SCREEN_MARGIN * 2
    let safeAreaBuffer = UIApplication.shared.windows[0].safeAreaInsets.top + UIApplication.shared.windows[0].safeAreaInsets.bottom
    let safeAreaHeight = UIScreen.main.bounds.height - safeAreaBuffer
    view.frame.size.height = safeAreaHeight - offsetTop - offsetBottom
    
  }
  
}
