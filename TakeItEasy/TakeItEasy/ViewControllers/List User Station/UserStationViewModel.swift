//
//  UserStationViewModel.swift
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

class UserStationViewModel: ViewModelProtocol {
    typealias DataSourceModel = Station
    
    private let bag = DisposeBag()
    
    // MARK: - Dependencies
    
    internal var managedObjectContext: NSManagedObjectContext
    
    // MARK: - Output
    
    final let dataSourceItems: Observable<[DataSourceModel]>
    
    // MARK: - Interface
    
    func delete(model: DataSourceModel) {
        do {
            try
                managedObjectContext.rx.delete(model)
        } catch {
            print(error)
        }
    }
    
    // MARK: - Initializer
    
    init(dependencies managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        
        dataSourceItems = managedObjectContext
            .rx
            .entities(DataSourceModel.self, sortDescriptors: nil)
            .asObservable()
        
    }
    
}
