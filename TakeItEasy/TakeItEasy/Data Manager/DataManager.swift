//
//  DataManager.swift
//  MangaPocket
//
//  Created by Jean Raphael on 26/07/2018.
//  Copyright © 2018 Jean Raphael. All rights reserved.
//

import UIKit

import CoreData
import RxCoreData
import RxSwift

class DataManager: DataManagerProtocol {
    
    static let shared = DataManager()
    
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        print("RxCoreData Location: - \(urls[urls.count-1] as URL)")
        
        return urls.last!
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "TakeItEasy", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("RxCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "TakeItEasy", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }()
    
    // MARK: - DataManagerProtocol
    
    func retrieveStations() -> Observable<[Station]> {
        return managedObjectContext
            .rx
            .entities(Station.self, sortDescriptors: nil)
    }
    
    func retrieveTravels() -> Observable<[Travel]> {
        return managedObjectContext
            .rx
            .entities(Travel.self, sortDescriptors: nil)
    }
    
    func save<T: Persistable>(model m: T) {
        do {
            try managedObjectContext
                .rx
                .update(m)
        } catch {
            fatalError("\(String(describing: self)) fail on update \(m)")
        }
    }
    
    func delete<T: Persistable>(model: T) {
        do {
            try
                managedObjectContext
                    .rx
                    .delete(model)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
