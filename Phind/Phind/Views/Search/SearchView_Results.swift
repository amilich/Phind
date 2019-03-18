//
//  SearchView_Results.swift
//  Phind
//
//  Created by Kevin Chang on 3/12/19.
//  Copyright © 2019 Team-7. All rights reserved.
//
import Foundation
import UIKit

/// Perform UI setup functions for the search results view controller
internal extension SearchViewController {
  
  /// Setup results style
  internal func setupResults() {
    
    // Setup results view.
    self.resultsView = UIView()
    self.resultsView.backgroundColor = UIColor.white
    Style.ApplyDropShadow(view: self.resultsView)
    Style.ApplyRoundedCorners(view: self.resultsView)
    Style.SetFullWidth(view: self.resultsView)
    self.view.addSubview(self.resultsView)
  
    Style.SetAlignment(view: self.resultsView,
                       offsetY: Style.FAB_HEIGHT + Style.ELEMENT_MARGIN,
                       align: Alignment.LEFT)
    Style.SetSize(view: self.resultsView,
                  offsetTop: Style.FAB_HEIGHT + Style.ELEMENT_MARGIN)
  
    // Setup table view.
    self.tableView = UITableView(frame: CGRect(
        x: 0, y: 0,
        width: resultsView.frame.size.width,
        height: resultsView.frame.size.height
    ))
    self.tableView.register(SearchResultsCell.self, forCellReuseIdentifier: "SearchResultsCell")
    self.tableView.dataSource = self
    self.tableView.delegate = self
    Style.ApplyRoundedCorners(view: self.tableView, clip: true)
    self.resultsView.addSubview(self.tableView)
    self.tableView.layoutMargins = UIEdgeInsets.zero
    self.tableView.separatorInset = UIEdgeInsets.zero
  
    // Setup no results text.
    self.noResultsLabel = UILabel()
    self.noResultsLabel.text = "No results found."
    self.noResultsLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
    self.noResultsLabel.textColor = Style.BODY_COLOR
    self.noResultsLabel.textAlignment = NSTextAlignment.center
    self.resultsView.addSubview(self.noResultsLabel)
    self.noResultsLabel.sizeToFit()
    self.noResultsLabel.center = CGPoint(x: self.resultsView.frame.size.width  / 2,
                                         y: self.resultsView.frame.size.height / 2)
  
    self.reloadView()
    
  }
  
  /// Delete all elements from timeline and add new entries. Then reload the tableView UIView to push the data to the screen.
  internal func reloadView() {
    
    // Iterate through location entries and draw them on the map.
    self.tableView.reloadData()
    self.tableView.isHidden = (self.results.count == 0)
    self.noResultsLabel.isHidden = (self.results.count != 0)
    
  }
    
}

/// Extend SearchViewController to be table data source
extension SearchViewController : UITableViewDataSource, UITableViewDelegate {
    
  /// The height of each cell in the table.
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
      // TODO: Make this a constant.
      return 80.0
    
  }
  
  /// The number of items in the table
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
      return self.results.count
    
  }
  
  /// Computes cell content based on the shared array of tableItems
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let result = self.results[indexPath.item]
    let tableCell = tableView.dequeueReusableCell(withIdentifier: "SearchResultsCell", for: indexPath) as! SearchResultsCell
    tableCell.placeTitleLabel!.text = result.name
  
    // Format last visit date.
    if !accessedFromEdit {
      let formatter = DateFormatter()
      formatter.dateFormat = "MMM d"
      let lastVisitDate = ModelManager.shared.getLastVisitDate(placeUUID: result.uuid) as Date?
    
      var subtitleText = "Visited \( ModelManager.shared.getNumberVisits(placeUUID: result.uuid) ?? 0 ) times"
      if lastVisitDate != nil {
        subtitleText += "  \u{00B7}  Last visited \( formatter.string(from: lastVisitDate!) )"
      }
      tableCell.subtitle!.text = subtitleText
      tableCell.layoutMargins = UIEdgeInsets.zero
    }
  
    return tableCell
    
  }

  /// Height for table cell
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return Style.ELEMENT_PADDING
  }
  
  /// Table footer height
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }
  
  /// Set content for search results cell
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
    let place = self.results[indexPath.item]
    self.closeSearch()
    if let mainVC = self.parent {
      if let mainVC = mainVC as? MainViewController {
        mainVC.placeDetailsController.updatePlaceForTimelineEntry(place: place)
        mainVC.placeDetailsController.setPlace(place: place)
        mainVC.timelineView.isHidden = true
        mainVC.placeDetailsController.setComponentsVisible(visible: true)
      }
    }
    
  }
    
}
