//
//  TakeItEasyTests.swift
//  TakeItEasyTests
//
//  Created by Jean Raphael on 06/01/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import TakeItEasy

class TakeItEasyTests: XCTestCase {
    
    let bag = DisposeBag()
    
    func test_when_fetch_milano_stations() {
        let asyncExpect = expectation(description: "fullfill test")
        
        TravelTrainAPI
            .trainStations(of: "milano centrale")
            .subscribe(onNext:{ stations in
                XCTAssertEqual(stations[0].id, "S01700")
                XCTAssertEqual(stations[0].name, "MILANO CENTRALE")
            }, onError: nil,
               onCompleted: {
                asyncExpect.fulfill()
            })
            .disposed(by: bag)
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test_when_fetch_train_departures() {
        let asyncExpect = expectation(description: "fullfill test")
        
        TravelTrainAPI
            .trainDepartures(of: "S01700")
            .subscribe(onNext: { departures in
                XCTAssertNotNil(departures)
                XCTAssertNotNil(departures[0])
            }, onError: { error in
                XCTAssertNil(error)
            }, onCompleted: {
                asyncExpect.fulfill()
            })
            .disposed(by: bag)
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test_when_fetch_train_arrivals() {
        let asyncExpect = expectation(description: "fullfill test")
        
        TravelTrainAPI
            .trainArrivals(of: "S01700")
            .subscribe(onNext: { arrivals in
                XCTAssertNotNil(arrivals)
                XCTAssertNotNil(arrivals[0])
            }, onError: { error in
                XCTAssertNil(error)
            }, onCompleted: {
                asyncExpect.fulfill()
            })
            .disposed(by: bag)
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test_when_fetch_train_sections() {
        let asyncExpect = expectation(description: "fullfill test")
        
        TravelTrainAPI
            .trainSections(of: "S02593", "10")
            .subscribe(onNext: { sections in
                XCTAssertNotNil(sections[0])
                                
                sections.forEach({ travelDetail in
                    if let detail = travelDetail {
                        debugPrint(detail)
                        
                        debugPrint(detail.departureHour)
                    }
                })
                
            }, onError: { error in
                XCTAssertNil(error)
            }, onCompleted: {
                asyncExpect.fulfill()
            })
            .disposed(by: bag)
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test_when_fetch_train_trend() {
        let asyncExpect = expectation(description: "fullfill test")
        
        TravelTrainAPI
            .trainTrend(of: "S00219", "10211")
            .subscribe(onNext: { section in
                XCTAssertNotNil(section)
            }, onError: { error in
                XCTAssertNil(error)
            }, onCompleted: {
                asyncExpect.fulfill()
            })
            .disposed(by: bag)
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
}
