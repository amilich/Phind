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

/// Extensions for the MainViewController to set proper style for timeline.
extension MainViewController {
  
  /// Register cell element and data source with the internal TableView.
  func setupTimelineView() {
    
    // Setup shadow.
    Style.ApplyDropShadow(view: timelineView)
    Style.ApplyRoundedCorners(view: timelineView)
    Style.SetFullWidth(view: timelineView)
    
    // Timeline card setup.
    Style.ApplyRoundedCorners(view: tableWrap, clip: true)
    tableWrap.frame.size.width = timelineView.frame.size.width

    // Timeline table setup.
    tableView.frame.size.width = timelineView.frame.size.width
    self.tableView.contentInset = UIEdgeInsets(top: 24, left: 0,bottom: 0, right: 0)
    
    self.tableView.register(TimelineUITableViewCell.self, forCellReuseIdentifier: "TimelineCell")
    self.tableView.separatorStyle = .none
    self.tableView.dataSource = self
    self.tableView.delegate = self
    
  }
  
  /// Delete all elements from timeline and add new entries. Then reload the tableView UIView to push the data to the screen.
  internal func reloadTimelineView() {
    
    // Iterate through location entries and draw them on the map.
    self.tableItems.removeAll()
    for locationEntry in self.locationEntries {
      addTimelineEntry(locationEntry)
    }
    self.tableView.reloadData()
    
  }
  
  /// Add an entry to the timeline.
  /// - parameter locationEntry: The location entry used to create a timeline entry; this entry is subsequently inserted to the set of items for the timeline table.
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
  }
  
}

/// Data source extensions for the MainViewController to manage the timeline TableView.
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
  
  /// Set the text for a timeline table cell.
  /// - parameter tableCell: The tableCell used to set text.
  /// - parameter timelineEntry: The TimelineEntry containing necessary information for the tableCell.
  func setupCellLabel(_ tableCell: TimelineUITableViewCell, _ timelineEntry: TimelineEntry) {
    
    // Update table cell fields.
    let cellLabel = tableCell.cellLabel
    if (timelineEntry.movementType == "STATIONARY") {
      cellLabel!.text = timelineEntry.placeLabel
    } else {
      cellLabel!.text = timelineEntry.movementType.capitalized
    }
    
  }
  
  /// Set the text and start/end times for a given timeline cell.
  /// - parameter tableCell: The tableCell used to set the time label.
  /// - parameter timelineEntry: The TimelineEntry containing necessary information for the tableCell.
  /// - parameter startTime: Start time for timeline entry.
  /// - parameter endTime: End time for timeline entry.
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
  
  /// Style and setup the duration UILabel in each table cell.
  /// - parameter tableCell: The tableCell used to set the time label.
  /// - parameter startTime: Start time for timeline entry.
  /// - parameter endTime: End time for timeline entry.
  func setupDurationLabel(_ tableCell: TimelineUITableViewCell,
                          _ startTime: Date, _ endTime: Date?) {
  
    // Calculate and assign duration of stay at location.
    let durationLabel = tableCell.durationLabel
    let duration : Int = abs (Int( startTime.timeIntervalSince(endTime ?? Date()) ))
    let hours : Int = Int (duration / 3600)
    let min : Int = Int( (duration % 3600) / 60 )
    durationLabel!.text = String(hours) + "h " + String(min) + "m"
  
  }
  
  /// Set the proper image for the given table cell.
  /// - parameter tableCell: The tableCell used to set the time label.
  /// - parameter timelineEntry: The timelineEntry is used to determine the movement type, which determines the proper image to use.
  /// - parameter indexPath: The indexPath determines which cell and information should be used.
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
  
  // The height of each cell in the table.
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    // TODO: Make this a constant.
    return 64.0
    
  }
  
  // The number of items in the table
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return self.tableItems.count
    
  }
  
  // Called when you tap a row in the table; displays the place popup
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let timelineIdx = indexPath[1]
    displayPlacePopup(selected: true, timelineEntry: self.tableItems[timelineIdx])
    
  }
  
}
