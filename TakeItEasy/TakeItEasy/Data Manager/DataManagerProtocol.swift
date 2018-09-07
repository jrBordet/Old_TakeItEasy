//
//  DataManagerProtocol.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 31/07/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import Foundation

import RxSwift
import RxCoreData

protocol DataManagerProtocol {
    func retrieveStations() -> Observable<[Station]>
    
    func retrieveTravels() ->  Observable<[Travel]>
    
    func save<T: Persistable>(model m: T)
    
    func delete<T: Persistable>(model: T)
}
