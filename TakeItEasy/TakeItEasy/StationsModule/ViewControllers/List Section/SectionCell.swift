//
//  SessionCell.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 19/01/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import UIKit

class SectionCell: UITableViewCell {

    @IBOutlet var stationLabel: UILabel!
    @IBOutlet var hourlabel: UILabel!
    @IBOutlet var currentStationLabel: UILabel!
    
    var isCurrentStation: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        if isCurrentStation {
//            hourlabel.textColor = .green
//            
//            stationLabel.transform = CGAffineTransform(scaleX: 2.6, y: 2.6)
//            stationLabel.alpha = 0.3
//            
//            UIView.animate(withDuration: 0.7, animations: {
//                self.stationLabel.transform = CGAffineTransform.identity
//                self.stationLabel.alpha = 1.0
//            })
//        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
