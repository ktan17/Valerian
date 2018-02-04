//
//  HeatMapCell.swift
//  Felix
//
//  Created by Christine Sun on 04/02/2018.
//  Copyright © 2018 Felix Inc. All rights reserved.
//

import UIKit

class HeatMapCell: UICollectionViewCell {
    
    func configure(emotion: StatEmotion, value: CGFloat, side: CGFloat) {

        switch emotion {
        case .HAPPY:
            self.backgroundColor = UIColor(red: 0.92, green: 0.28, blue: 0.25, alpha: 1.00)
        case .SAD:
            self.backgroundColor = UIColor(red: 0.06, green: 0.80, blue: 0.48, alpha: 1.00)
        case .ANGRY:
            self.backgroundColor = UIColor(red: 0.22, green: 0.33, blue: 0.49, alpha: 1.00)
        case .ANXIOUS:
            self.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.00)
        }
        
        self.alpha = value
        self.frame.size = CGSize(width: side, height: side)
        
    }
    
}
