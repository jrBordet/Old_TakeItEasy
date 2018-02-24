//
//  Section.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 28/01/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import UIKit

struct Section {
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

