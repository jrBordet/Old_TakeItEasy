//
//  Section.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 28/01/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import UIKit

struct Section {
    let current: Bool
    let departure: Int
    let arrival: Int
    let station: String
    let delay: Int
    let last: Bool
    
    private let dateFormatter = DateFormatter()

    
    // MARK: - Departure
    
    var departureDate: Date {
        get {
            return Date(timeIntervalSince1970: TimeInterval(departure / 1000))
        }
    }
    
    var departureHour: String {
        get {
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            
            dateFormatter.locale = Locale(identifier: "it_IT")
            
            return dateFormatter.string(from: departureDate)
        }
    }
    
    // MARK: - Arrival
    
    var arrivalDate: Date {
        get {
            return Date(timeIntervalSince1970: TimeInterval(arrival / 1000))
        }
    }
    
    var arrivalHour: String {
        get {
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            
            dateFormatter.locale = Locale(identifier: "it_IT")
            
            return dateFormatter.string(from: arrivalDate)
        }
    }
    
    // MARK: - Init
    
    init(_ current: Bool, departure: Int, arrival: Int, station: String, delay: Int, last: Bool) {
        self.current = current
        self.departure = departure
        self.arrival = arrival
        self.station = station
        self.delay = delay
        self.last = last
    }
}

