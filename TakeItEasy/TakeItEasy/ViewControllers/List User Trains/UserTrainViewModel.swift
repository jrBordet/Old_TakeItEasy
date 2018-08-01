//
//  UserTrainViewModel.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 13/07/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Action

enum Update: Int {
    case departure
    case arrivals
    
    mutating func toogle() {
        switch self {
        case .departure:
            self = .arrivals
        case .arrivals:
            self = .departure
        }
    }
}

protocol ViewModelProtocol {
    associatedtype DataSourceModel
    
    var dataManager: DataManagerProtocol { get }
}

typealias inputType = (station: Station, date: Date)

class UserTrainViewModel: ViewModelProtocol {
    typealias DataSourceModel = Travel
    
    private let bag = DisposeBag()
    
    // MARK: - Dependencies
    
    internal var dataManager: DataManagerProtocol
    
    // MARK: - Output
    
    final var travelItems: Observable<[DataSourceModel]>
    
    var fetchTravels: Action<(direction: Update, date: Date), [Travel?]>!
    
    var stationName: String?

    // MARK: - Interface

    final func delete(model: DataSourceModel) {
        dataManager.delete(model: model)
    }
    
    final func save(travel t: Travel) {
        dataManager.save(model: t)
    }
    
    // MARK: - Initializer
    
    init(dependencies dataManager: DataManagerProtocol) {
        self.dataManager = dataManager
        
        self.travelItems = dataManager.retrieveTravels()
    }
    
    convenience init(dependencies dataManager: DataManagerProtocol, input: inputType) {
        self.init(dependencies: dataManager)
        
        self.stationName = input.station.name
        
        self.fetchTravels = Action { action -> Observable<[Travel?]> in
            if action.direction == .departure {
                return TravelTrainAPI
                    .trainDepartures(of: input.station.id,
                                     date: action.date)
            } else {
                return TravelTrainAPI
                    .trainArrivals(of: input.station.id,
                                   date: action.date)
            }
        }
    }
    
}
