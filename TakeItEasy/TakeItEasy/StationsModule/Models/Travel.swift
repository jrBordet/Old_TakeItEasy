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
    let current: Bool
    let departure: Int
    let arrival: Int
    let station: String
    let delay: Int
    
    var departureDate: Date {
        get {
            return Date(timeIntervalSince1970: TimeInterval(departure / 1000))
        }
    }
    
    var departureHour: String {
        get {
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            
            dateFormatter.locale = Locale(identifier: "it_IT")
            
            return dateFormatter.string(from: departureDate)
        }
    }

    init(_ number: Int, current: Bool, departure: Int, arrival: Int, station: String, delay: Int) {
        self.number = number
        self.current = current
        self.departure = departure
        self.arrival = arrival
        self.station = station
        self.delay = delay
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
