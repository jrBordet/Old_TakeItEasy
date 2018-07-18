//
//  UserTrainViewModelTests.swift
//  TakeItEasyTests
//
//  Created by Jean Raphael on 13/07/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import XCTest

import RxSwift

import RxCocoa
import CoreData

import Action

@testable import TakeItEasy

class UserTrainViewModelTests: XCTestCase {
    
    let bag = DisposeBag()
    
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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func test_when_viewmodel_fetch_trains() {
        let viewModel = UserTrainViewModel(dependencies: managedObjectContext)
        
        viewModel
            .travelItems
            .subscribe { Travels in
            XCTAssertNotNil(Travels)
        }
        .disposed(by: bag)
    }
    
    func test_when_fetch_train_departures() {
        let expectation = XCTestExpectation(description: "Fetch departures from Torino Porta Nuova")
        
        // Torino porta nuova S00219
        let viewModel = UserTrainViewModel(dependencies: managedObjectContext,
                                           input: (stationCode: "S00219", date: Date()))
        
        viewModel
            .fetchTravels
            .execute((direction: .departure, date: Date()))
            .subscribe(onNext: { travels in
                XCTAssertNotNil(travels.first ?? nil)
                
                expectation.fulfill()
            })
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func test_when_fetch_train_arrivals() {
        let expectation = XCTestExpectation(description: "Fetch arrivals from Torino Porta Nuova")
        
        // Torino porta nuova S00219
        let viewModel = UserTrainViewModel(dependencies: managedObjectContext,
                                           input: (stationCode: "S00219", date: Date()))
        
        viewModel
            .fetchTravels
            .execute((direction: .arrivals, date: Date()))
            .asObservable()
            .subscribe(onNext: { travels in
                XCTAssertNotNil(travels.first ?? nil)
                
                expectation.fulfill()
            })
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
