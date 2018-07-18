//
//  UserTrainViewModel.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 13/07/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import Foundation

import CoreData
import RxCoreData

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
    
    var managedObjectContext: NSManagedObjectContext { get }
}

typealias inputType = (stationCode: String, date: Date)

class UserTrainViewModel: ViewModelProtocol {
    typealias DataSourceModel = Travel
    
    private let bag = DisposeBag()
    
    // MARK: - Dependencies
    
    internal var managedObjectContext: NSManagedObjectContext
    
    // MARK: - Output
    
    final var travelItems: Observable<[DataSourceModel]>
    
    // MARK: - Interface
    
    var fetchTravels: Action<(direction: Update, date: Date), [Travel?]>!

    final func delete(model: DataSourceModel) {
        do { try
            managedObjectContext.rx.delete(model)
        } catch {
            print(error)
        }
    }
    
    final func save(travel t: Travel) {
        do { try managedObjectContext.rx.update(t)
        } catch {
            fatalError("\(String(describing: self)) fail on update \(t)")
        }
    }
    
    // MARK: - Initializer
    
    init(dependencies managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        
        self.travelItems = managedObjectContext
            .rx
            .entities(Travel.self, sortDescriptors: nil)
            .asObservable()
    }
    
    convenience init(dependencies managedObjectContext: NSManagedObjectContext, input: inputType) {
        self.init(dependencies: managedObjectContext)
        
        self.fetchTravels = Action { action -> Observable<[Travel?]> in
            if action.direction == .departure {
                return TravelTrainAPI
                    .trainDepartures(of: input.stationCode,
                                     date: action.date)
                    .asObservable()
            } else {
                return TravelTrainAPI
                    .trainArrivals(of: input.stationCode,
                                   date: action.date)
                    .asObservable()
            }
        }
    }
    
}
