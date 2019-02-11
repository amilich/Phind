//
//  TimelineUITableViewCell.swift
//  Phind
//
//  Created by Andrew B. Milich on 2/10/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit

class TimelineUITableViewCell: UITableViewCell {
  
  @IBOutlet var cellImage: UIImageView!
  
  @IBOutlet var cellLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib();
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    // TODO(Andrew) write code to make it selected if we want
  }
}
