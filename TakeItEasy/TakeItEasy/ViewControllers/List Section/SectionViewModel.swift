//
//  SectionViewModel.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 18/07/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Action

class SectionViewModel {
    
    // MARK: - Output
    
    let fetchSection: Action<Bool, [Section?]>
    
    let trainStatus: Driver<String>
    
    let trainNumber: Driver<String>
    
    // MARK: - Initializer
    
    init(travel: Travel) {
        
        self.fetchSection = Action { action -> Observable<[Section?]> in
            return TravelTrainAPI
                .trainSections(of: travel.originCode, String(travel.number))
                .asObservable()
        }
        
        self.trainStatus = Observable<String>
            .just(travel.state)
            .asDriver(onErrorJustReturn: "")
        
        self.trainNumber = Observable<String>
            .just(String(travel.number))
            .asDriver(onErrorJustReturn: "")
    }
}
