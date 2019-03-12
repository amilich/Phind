//
//  MainView_Header.swift
//  Phind
//
//  All logic as it pertains to the main view header goes here.
//
//  Created by Kevin Chang on 3/3/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import UIKit

/// Extend the MainViewController with all functions necessary to control the date picker header.
internal extension MainViewController {
  
  /// Action selector when user clicks refresh button
  @IBAction func refreshButton(_ sender: Any) {
    // Triggers MainViewController reloadView()
    self.reloadView()
  }
  
  /// Action button selector to scroll to the previous day
  @IBAction func previousDayButton(_ sender: Any) {
    updateDate(Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!)
    self.reloadView()
  }
  
  /// Action button selector to advance the date viewer to the next day
  @IBAction func nextDayButton(_ sender: Any) {
    updateDate(Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!)
    self.reloadView()
  }
  
  /// Setup the style for the header view coomponent
  internal func setupHeaderView() {
    
    // Setup header view.
    headerView.backgroundColor = Style.PRIMARY_COLOR
    // Add corners, shadow, and frame style settings.
    Style.ApplyDropShadow(view: headerView)
    Style.ApplyRoundedCorners(view: headerView)
    Style.SetFullWidth(view: headerView)
    headerView.frame.origin.y = UIApplication.shared.windows[0].safeAreaInsets.top
    
  }
  
}