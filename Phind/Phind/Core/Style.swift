//
//  Style.swift
//  Phind
//
//  Created by Kevin Chang on 3/3/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import UIKit

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
  
  public static let SCREEN_MARGIN : CGFloat = 12
  public static let CARD_CORNERS : CGFloat = 24
  public static let PHOTO_BORDER : CGFloat = 84.0
}

extension Style {
  
  public static func ApplyRoundedCorners(view: UIView, clip: Bool = false) {
    view.layer.cornerRadius = Style.CARD_CORNERS
    view.clipsToBounds = clip
  }
  
  public static func ApplyDropShadow(view: UIView) {
    
    view.layer.shadowOpacity = 0.16
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    view.layer.shadowRadius = 4.0
    
  }
  
  public static func SetFullWidth(view: UIView, positionWithMargin: Bool = true) {
    view.frame.size.width = UIScreen.main.bounds.width - Style.SCREEN_MARGIN * 2
    if (positionWithMargin) {
      view.frame.origin.x = Style.SCREEN_MARGIN
    }
  }
  
}
