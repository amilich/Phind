//
//  StatisticsUICollectionViewCell.swift
//  Phind
//
//  Created by Dhruv Kedia on 2/12/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import UIKit

class StatisticsUICollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var StatValue: UILabel!
    @IBOutlet var StatType: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        StatValue = UILabel()
        StatValue.frame = CGRect(x: 44, y: 20, width: 300, height: 80)
        StatValue.font = UIFont(name: "Roboto", size: 17)
        StatType = UILabel()
        StatType.frame = CGRect(x: 44, y: 2, width: 300, height: 80)
        StatType.font = UIFont(name: "Roboto", size: 17)
        self.contentView.addSubview(StatType)
        self.contentView.addSubview(StatValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
    }

}
