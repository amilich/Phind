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
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    // Create the UILabel for place name
    cellLabel = UILabel()
    cellLabel.frame = CGRect(x: 94, y: 16, width: 300, height: 40)
    cellLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 15)
    
    // Create UIImage
    // TODO(Andrew) set UIImage differently for first and last timeline
    // items.
    let imagePath = "timeline_icon_temp.png"
    let image = UIImage(named: imagePath)
    cellImage = UIImageView(image: image!)
    cellImage.frame = CGRect(x: 25, y: 10, width: 50, height: 50)
    cellImage.contentMode = UIView.ContentMode.scaleAspectFill;

    self.contentView.addSubview(cellImage)
    self.contentView.addSubview(cellLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func awakeFromNib() {
    super.awakeFromNib();
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    // TODO(Andrew) write code to make it selected if we want
  }
}
