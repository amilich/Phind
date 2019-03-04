//
//  EditPlaceViewController.swift
//  Phind
//
//  Created by Andrew B. Milich on 2/27/19.
//  Copyright © 2019 Team-7. All rights reserved.
//
import UIKit
import MapKit
import RealmSwift
import GoogleMaps
import GooglePlaces

class EditPlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
  
  // Data storage elements
  public var place = Place()
    
  // Private variables
  private var sharedURLSession = AppDelegate().sharedUrlSession
  let gmsApiKey = AppDelegate().gmsApiKey
    
  // Table content for dynamically reusable cells
  private var tableItems: [String] = []
    
  // UI components
  let backButton = UIButton()
  var tableView = UITableView()
  let searchController = UISearchController(searchResultsController: nil)
    
  init() {
    super.init(nibName: nil, bundle: nil)
    
    self.definesPresentationContext = true
    
    backButton.frame = CGRect(x: 10, y: 15, width: 50, height: 50)
    backButton.setImage(UIImage(named: "back.png"), for: .normal)
    backButton.setTitle("Back", for: .normal)
    backButton.addTarget(self, action: #selector(self.backPressed(_:)), for: .touchUpInside)
        
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search for place"
    self.navigationItem.searchController = searchController
    self.navigationItem.hidesSearchBarWhenScrolling = false
    
    tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = UIColor.white
    tableView.tableHeaderView = searchController.searchBar
    
    let backButtonMaxY = backButton.frame.maxY
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myIdentifier")
    tableView.frame = CGRect(x: 0, y: backButtonMaxY, width: self.view.frame.width, height: self.view.frame.height - backButtonMaxY)
    
    self.view.addSubview(tableView)
    self.view.addSubview(backButton)
    self.view.addSubview(searchController.view)
    
    self.view.backgroundColor = .white
    self.view.isHidden = true
  }

  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Prepare place edit view for loading
  override func viewDidLoad() {
  }
  
  // TODO: add table view in here with nearby places
  @objc func backPressed(_ sender: UIButton!) {
    self.view.isHidden = !self.view.isHidden
    print("here")
    if let popupVC = self.parent as? PlacePopupViewController {
        print("Found parent")
        // TODO the parent of this will be the popup controller.
        // If the place is edited, the poopup controller will have
        // to refresh its content.
        // popupVC.setPlace(place: newPlace)
    }
  }

    // Called to set the place to be displayed on the popup view.
    public func setPlace(place: Place) {
        self.place = place
        // delete old table items
        self.tableItems.removeAll()
        self.getNearestPlaces()
        self.tableView.reloadData()
        
        // TODO, delete from Realm if place is changed
         // backPressed will trigger update in parent
        //        self.label.text = self.place.name
        //        self.addressLabel.text = self.place.address
        //        // Get rid of the previous image
        //        self.placeImages.removeAll()
        //        self.photoCollection.reloadData()
        //        // Now load a new image
        //        self.loadPhotoForPlaceID(gms_id: place.gms_id)
    }


    private func getNearestPlaces() {
//        return ["a", "b", "c", "d"]
    // TODO: fill in with call to nearest places API
        let nearbySearchUrl = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(self.place.latitude),\(self.place.longitude)&rankby=distance&key=\(gmsApiKey)")!

        print(nearbySearchUrl)

        let nearbySearchTask = sharedURLSession.dataTask(with: nearbySearchUrl) { (data, response, error) in
            var nearbyPlaces = [String]()
            
            let nearbySearchResponse = ModelManager.shared.getNearbySearchResponse(data: data, response: response, error: error)
            if nearbySearchResponse == nil {
                print("No nearby places found.")
                return
            }

            // look for associated place in Realm; if it doesn't exist, create it
            let nearestPlaceResults = nearbySearchResponse!.prefix(5)

            for nearestPlaceResult in nearestPlaceResults {
                let name = nearestPlaceResult["name"] as! String
                nearbyPlaces.append(name)
                // write all to realm?
            }

            self.tableItems = nearbyPlaces
            self.tableView.reloadData()

        }
        nearbySearchTask.resume()
}

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.tableItems.count
  }

  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "myIdentifier", for: indexPath)
    cell.textLabel?.text = "\(self.tableItems[indexPath.row])"
    return cell
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    // TODO update results
  }
}
    


    

