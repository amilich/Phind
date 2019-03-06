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

internal extension MainViewController {
  
  @IBAction func refreshButton(_ sender: Any) {
    self.reloadView()
  }
  
  @IBAction func previousDayButton(_ sender: Any) {
    updateDate(Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!)
    self.reloadView()
  }
  
  @IBAction func nextDayButton(_ sender: Any) {
    updateDate(Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!)
    self.reloadView()
  }
  
  
  internal func setupHeaderView() {
    
    // Setup header view.
    headerView.backgroundColor = Style.PRIMARY_COLOR
    
    Style.ApplyDropShadow(view: headerView)
    Style.ApplyRoundedCorners(view: headerView)
    Style.SetFullWidth(view: headerView)
    headerView.frame.origin.y = UIApplication.shared.windows[0].safeAreaInsets.top
    
  }
  
}
