//
//  StationModule.swift
//  ViaggioTreno
//
//  Created by Jean Raphael on 16/11/2017.
//  Copyright © 2017 Jean Raphael. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import RxCoreData
import RxDataSources

class RouterStation {
    var navigation: UINavigationController!
    
    let bag = DisposeBag()
    
    final func assembleModule() -> UIViewController {
        
        navigation = UINavigationController(rootViewController: createListUserStationViewController())
        
        navigation?.navigationBar.isHidden = true
        
        return navigation
    }
    
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
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
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
    
    
    // MARK: - Factory methods
    
    private func createListUserStationViewController() -> UIViewController {
        let listUserStationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserStationViewController") as! ListUserStationViewController
        
        listUserStationViewController.coordinatorDelegate = self as ListUserStationCoordinator
        listUserStationViewController.managedObjectContext = managedObjectContext
        
        return listUserStationViewController
    }
    
    private func createListSpotlightViewController() -> UIViewController {
        let listSpotlightViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListSpotlightViewController") as! ListSpotlightViewController
        
        listSpotlightViewController.coordinatorDelegate = self as ListSpotlightCoordinator
        listSpotlightViewController.managedObjectContext = managedObjectContext
        
        return listSpotlightViewController
    }
    
    private func createListTrainViewController(of station: Station) -> UIViewController {
        let listTrainsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TrainsViewController") as! ListTrainsViewController
        
        listTrainsViewController.station = station
        listTrainsViewController.coordinatorDelegate = self
        
        return listTrainsViewController
    }
    
    private func createListSectionViewController(of travel: Travel) -> UIViewController {
        let listSectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SectionViewController") as! ListSectionViewController
        
        listSectionViewController.travel = travel
        
        return listSectionViewController
    }
}

// MARK: - ListTrainsCoordinator

extension RouterStation: ListTrainsCoordinator {
    func showTravelDetail(of travel: Travel) {
        navigation.pushViewController(createListSectionViewController(of: travel), animated: true)
    }
}

// MARK: - ListSpotlightCoordinator

extension RouterStation: ListSpotlightCoordinator {
    func showTrains(of station: Station) {
        navigation.pushViewController(createListTrainViewController(of: station), animated: true)
    }
    
    func showMyStations() {
        navigation.dismiss(animated: true, completion: nil)
    }
}

// MARK: - ListUserStationCoordinator

extension RouterStation: ListUserStationCoordinator {
    func showDepartures(of station: Station) {
        navigation.pushViewController(createListTrainViewController(of: station), animated: true)
    }
    
    func showTrainSpootlight() {
        navigation.present(createListSpotlightViewController(), animated: true, completion: nil)
    }
}
