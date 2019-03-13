//
//  SearchView_Results.swift
//  Phind
//
//  Created by Kevin Chang on 3/12/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import UIKit

internal extension SearchViewController {
  
  internal func SetupResults() {
    
    resultsView = UIView()
    resultsView.backgroundColor = UIColor.white
    Style.ApplyDropShadow(view: resultsView)
    Style.ApplyRoundedCorners(view: resultsView)
    Style.SetFullWidth(view: resultsView)
    self.view.addSubview(resultsView)
    
    Style.SetAlignment(view: resultsView,
                       offsetY: Style.FAB_HEIGHT + Style.ELEMENT_MARGIN,
                       align: Alignment.LEFT)
    Style.SetSize(view: resultsView,
                  offsetTop: Style.FAB_HEIGHT + Style.ELEMENT_MARGIN)
    
  }

}
