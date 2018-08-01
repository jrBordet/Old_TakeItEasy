//
//  SessionCell.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 19/01/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class SectionCell: UITableViewCell {
    @IBOutlet var stationLabel: UILabel!
    @IBOutlet var hourlabel: UILabel!
    @IBOutlet var railLabel: UILabel!
}

extension Reactive where Base: SectionCell {
    var sectionResult: Binder<SectionResult> {
        return Binder(base) { cell, result in
            cell.hourlabel.textColor = result.textColor
            cell.hourlabel.text = result.hour
            cell.stationLabel.text = result.station.capitalized
        }
    }
}
