//
//  Travel.swift
//  ViaggioTreno
//
//  Created by Jean Raphael on 03/12/2017.
//  Copyright © 2017 Jean Raphael. All rights reserved.
//

import Foundation

struct Travel {
    let number: Int
    let originCode: String
    let category: String
    let direction: String
    let time: String
    let state: String
    
    init(_ number: Int, originCode: String, category: String, time: String, direction: String, state: String) {
        self.number = number
        self.originCode = originCode
        self.category = category
        self.time = time
        self.direction = direction
        self.state = state
    }
    
}
