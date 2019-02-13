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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        StatValue = UILabel()
        StatValue.frame = CGRect(x: 94, y: 10, width: 300, height: 29)
        StatValue.font = UIFont(name: "Roboto", size: 40)
        self.contentView.addSubview(StatValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
    }

}
