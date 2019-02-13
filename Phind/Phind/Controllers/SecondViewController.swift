//
//  SecondViewController.swift
//  Phind
//
//  Created by Andrew B. Milich on 1/26/19.
//  Copyright © 2019 Team-7. All rights reserved.
//
import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import RealmSwift


class StatisticLabel1: NSObject {
    var stat1: String
    
    init(stat1: String) {
        self.stat1 = stat1
        super.init()
    }
}

class SecondViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let realm = try! Realm()
    
    var collectionItems: [StatisticLabel1] = []
    
    override func viewWillAppear(_ animated: Bool) {
        populateCollectionView()
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView();
    populateCollectionView();
  }


  func populateCollectionView(){
    self.collectionItems.removeAll()
    let locationEntries = ModelManager.shared.getLocationEntries()
    var count = 0
    for locationEntry in locationEntries {
        if locationEntry.movement_type == MovementType.STATIONARY.rawValue{
            count = count + 1
        }
    }
    let numberPlaces = String(count)
    print("numberPlaces:", numberPlaces)
    let statisticLabel1 = StatisticLabel1(stat1: numberPlaces)
    self.collectionItems.append(statisticLabel1)
    collectionView.reloadData()
  }
  
  func setupCollectionView() {
    self.collectionView.register(StatisticsUICollectionViewCell.self, forCellWithReuseIdentifier:
        "StatisticsCell")
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
  }
}

extension SecondViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatisticsCell", for: indexPath) as! StatisticsUICollectionViewCell
        
        let firstStat = self.collectionItems[indexPath.item]
        
        let StatValue = collectionCell.StatValue
        StatValue!.text = firstStat.stat1
        return collectionCell
    }
    
    
}
