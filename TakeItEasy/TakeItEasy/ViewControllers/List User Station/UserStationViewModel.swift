//
//  UserStationViewModel.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 13/07/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import Action

class UserStationViewModel: ViewModelProtocol {
    typealias DataSourceModel = Station
    
    private let bag = DisposeBag()
    
    // MARK: - Dependencies
    
    internal var dataManager: DataManagerProtocol
    
    // MARK: - Output
    
    final let dataSourceItems: Observable<[DataSourceModel]>
    
    // MARK: - Interface
    
    func delete(model: DataSourceModel) {
        dataManager.delete(model: model)
    }
    
    // MARK: - Initializer
    
    init(dependencies dataManager: DataManagerProtocol) {
        self.dataManager = dataManager
        
        dataSourceItems = self.dataManager.retrieveStations()
        
    }
    
}
