//
//  String+Extensions.swift
//  ViaggioTreno
//
//  Created by Jean Raphael on 03/12/2017.
//  Copyright © 2017 Jean Raphael. All rights reserved.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst().lowercased()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
