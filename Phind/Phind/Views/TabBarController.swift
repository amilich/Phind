//
//  TabBarController.swift
//  Phind
//
//  Created by Andrew B. Milich on 2/13/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit
import TransitionableTab

// Basic animated TransitionableTab controller
// https://github.com/Interactive-Studio/TransitionableTab

class TabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
  }
}

extension TabBarController: TransitionableTab {
  
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    return animateTransition(tabBarController, shouldSelect: viewController)
  }
}
