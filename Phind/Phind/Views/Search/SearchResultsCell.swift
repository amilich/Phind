//
//  SearchResultsViewCell.swift
//  Phind
//
//  Created by Kevin Chang on 3/13/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import UIKit

/// Custom search results cell for search controller
class SearchResultsCell: UITableViewCell {
    
  @IBOutlet var placeTitleLabel: UILabel!
  @IBOutlet var subtitle: UILabel!
  
  /// Constructor for timeline cell
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    // Create UILabel for place name
    placeTitleLabel = UILabel()
    placeTitleLabel.frame = CGRect(x: 24, y: 16, width: 240, height: 24)
    placeTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
    
    // Create UILabel for number of times visited.
    subtitle = UILabel()
    subtitle.frame = CGRect(x: 24, y: 40, width: 240, height: 24)
    subtitle.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
    
    self.contentView.addSubview(placeTitleLabel)
    self.contentView.addSubview(subtitle)
  }
  
  /// Constructor required for storyboard use
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
}
