//
//  Travel.swift
//  ViaggioTreno
//
//  Created by Jean Raphael on 03/12/2017.
//  Copyright © 2017 Jean Raphael. All rights reserved.
//

import Foundation

struct TravelDetail {
    let number: Int
    let category: String
    let current: Bool
    let departure: String
    let arrival: String
    let direction: String
    let state: String

    init(_ number: Int, category: String, current: Bool, departure: String, arrival: String, direction: String, state: String) {
        self.number = number
        self.category = category
        self.current = current
        self.departure = departure
        self.arrival = arrival
        self.direction = direction
        self.state = state
    }
}

struct Travel {
    let number: Int
    let category: String
    let direction: String
    let time: String
    let state: String
    
    init(_ number: Int, category: String, time: String, direction: String, state: String) {
        self.number = number
        self.category = category
        self.time = time
        self.direction = direction
        self.state = state
    }
    
}
