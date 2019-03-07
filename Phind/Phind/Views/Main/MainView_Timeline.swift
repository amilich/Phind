//
//  MainView_Timeline.swift
//  Phind
//
//  All logic as it pertains to the main view timeline goes here.
//
//  Created by Kevin Chang on 3/3/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import UIKit
import JustLog

extension MainViewController {
  
  // Register cell element and data source with table view
  func setupTimelineView() {
    
    // Setup shadow.
    Style.ApplyDropShadow(view: shadowWrap)
    Style.ApplyRoundedCorners(view: shadowWrap)
    Style.SetFullWidth(view: shadowWrap)
    
    // Timeline card setup.
    Style.ApplyRoundedCorners(view: tableWrap, clip: true)
    tableWrap.frame.size.width = shadowWrap.frame.size.width

    // Timeline table setup.
    tableView.frame.size.width = shadowWrap.frame.size.width
    self.tableView.contentInset = UIEdgeInsets(top: 24, left: 0,bottom: 0, right: 0)
    
    self.tableView.register(TimelineUITableViewCell.self, forCellReuseIdentifier: "TimelineCell")
    self.tableView.separatorStyle = .none
    self.tableView.dataSource = self
    self.tableView.delegate = self
    
  }
  
  internal func reloadTimelineView() {
    
    // Iterate through location entries and draw them on the map.
    self.tableItems.removeAll()
    for locationEntry in self.locationEntries {
      addTimelineEntry(locationEntry)
    }
    self.tableView.reloadData()
    
  }
  
  func addTimelineEntry(_ locationEntry: LocationEntry) {
    
    let place = ModelManager.shared.getPlace(locationEntry: locationEntry)
    if place != nil {
      let timelineEntry = TimelineEntry(
        placeUUID: place!.uuid,
        placeLabel: place!.name,
        startTime: locationEntry.start as Date,
        endTime: locationEntry.end as Date?,
        movementType: locationEntry.movement_type
      )
      self.tableItems.insert(timelineEntry, at: 0)
    }
    // TODO: What do we do if place ID is nil?
    
  }
  
}

extension MainViewController :  UITableViewDataSource {
  
  // Computes cell content based on the shared array of tableItems
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let tableCell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell", for: indexPath) as! TimelineUITableViewCell
    
    // Get the location description string set by the TimelineController
    let timelineEntry = self.tableItems[indexPath.item]
    let startTime = timelineEntry.startTime as Date
    let endTime = timelineEntry.endTime as Date?
    
    // Setup all the labels and elements of the table cell.
    self.setupCellLabel(tableCell, timelineEntry)
    self.setupTimeLabel(tableCell, timelineEntry, startTime, endTime)
    self.setupDurationLabel(tableCell, startTime, endTime)
    self.setupTimelineImage(tableCell, timelineEntry, indexPath)
    
    return tableCell
    
  }
  
  func setupCellLabel(_ tableCell: TimelineUITableViewCell, _ timelineEntry: TimelineEntry) {
    
    // Update table cell fields.
    let cellLabel = tableCell.cellLabel
    if (timelineEntry.movementType == "STATIONARY") {
      cellLabel!.text = timelineEntry.placeLabel
    } else {
      cellLabel!.text = timelineEntry.movementType.capitalized
    }
    
  }
  
  func setupTimeLabel(_ tableCell: TimelineUITableViewCell,
                      _ timelineEntry: TimelineEntry,
                      _ startTime: Date, _ endTime: Date?) {
    
    // Update time label.
    let timeLabel = tableCell.timeLabel
    timeLabel!.text = ""
    if (timelineEntry.movementType == "STATIONARY") {
      formatter.dateFormat = "h:mm a"
      let startTimeString = formatter.string(from: startTime)
      let endTimeString = (endTime != nil) ? formatter.string(from: endTime!) : "now"
      let timeString = String(format: "from %@ to %@", startTimeString, endTimeString)
      timeLabel!.text = timeString
    }
    
  }
  
  func setupDurationLabel(_ tableCell: TimelineUITableViewCell,
                          _ startTime: Date, _ endTime: Date?) {
  
    // Calculate and assign duration of stay at location.
    let durationLabel = tableCell.durationLabel
    let duration : Int = abs (Int( startTime.timeIntervalSince(endTime ?? Date()) ))
    let hours : Int = Int (duration / 3600)
    let min : Int = Int( (duration % 3600) / 60 )
    durationLabel!.text = String(hours) + "h " + String(min) + "m"
  
  }
  
  func setupTimelineImage(_ tableCell: TimelineUITableViewCell,
                          _ timelineEntry: TimelineEntry,
                          _ indexPath: IndexPath) {
    
    // Assign proper UIImage.
    let cellImage = tableCell.cellImage!
    if (timelineEntry.movementType != "STATIONARY") {
      cellImage.image = UIImage(named: "timeline_line.png")
    } else if (indexPath.item == 0) {
      cellImage.image = UIImage(named: "timeline_joint_first.png")
    } else if indexPath.item == self.tableItems.count - 1 {
      cellImage.image = UIImage(named: "timeline_joint_last.png")
    } else {
      cellImage.image = UIImage(named: "timeline_joint.png")
    }
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    // TODO: Make this a constant.
    return 64.0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.tableItems.count
  }
  
  // Called when you tap a row in the table; displays the place popup
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let timelineIdx = indexPath[1]
    displayPlacePopup(selected: true, timelineEntry: self.tableItems[timelineIdx])
  }
  
}
