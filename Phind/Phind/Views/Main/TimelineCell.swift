//
//  TimelineUITableViewCell.swift
//  Phind
//
//  Created by Andrew B. Milich on 2/10/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit

/// The TimelineUITableViewCell stores the requisite UI components for displaying the timeline value to the user, including a label, image, duration, and time.
class TimelineCell: UITableViewCell {
  
  /// The image for the timelineEntry
  @IBOutlet var cellImage: UIImageView!
  /// Main label for timelineLabel (typically place or movement type)
  @IBOutlet var cellLabel: UILabel!
  /// The duration for the timeline
  @IBOutlet var durationLabel: UILabel!
  /// The time length for the timeline component (placed below main label)
  @IBOutlet var timeLabel: UILabel!
  
  /// Constructor for timeline cell. Sets up style for the internal place label, duration label, time label, and image.
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    // TODO: Set this up to be more general purpose.
    
    // Create UILabel for place name
    cellLabel = UILabel()
    cellLabel.frame = CGRect(x: 136, y: 8, width: 192, height: 24)
    cellLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
    
    // Create UILabel for place duration.
    durationLabel = UILabel()
    durationLabel.frame = CGRect(x: 24, y: 8, width: 64, height: 24)
    durationLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
    durationLabel.textColor = Style.SECONDARY_COLOR
    durationLabel.textAlignment = .right
    
    // Create UILabel for time
    timeLabel = UILabel()
    timeLabel.frame = CGRect(x: 136, y: 32, width: 192, height: 16)
    timeLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
    timeLabel.textColor = Style.BODY_COLOR

    // Create UIImage
    // TODO(Andrew) set UIImage differently for first and last timeline
    // items.
    let imagePath = "timeline_joint.png"
    let image = UIImage(named: imagePath)
    cellImage = UIImageView(image: image!)
    cellImage.frame = CGRect(x: 100, y: 0, width: 24, height: 64)
    cellImage.contentMode = UIView.ContentMode.scaleAspectFit;

    self.contentView.addSubview(cellLabel)
    self.contentView.addSubview(timeLabel)
    self.contentView.addSubview(durationLabel)
    self.contentView.addSubview(cellImage)
  }
  
  /// Coder/decoder init (needed for use as a storyboard component)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Called when user selects a timeline component
  override func setSelected(_ selected: Bool, animated: Bool) {
    // TODO(Andrew) write code to make it selected if we want
    // super.setSelected(selected, animated: animated)    
  }
}
