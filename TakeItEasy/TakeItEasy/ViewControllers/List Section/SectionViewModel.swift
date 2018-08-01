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

enum SectionResult {
    case current(hour: String, name: String)
    case normal(hour: String, name: String)
}

extension SectionResult {
    var textColor: UIColor {
        switch self {
        case .current:
            return UIColor(named: "primayGreen") ?? .green
        case .normal:
            return UIColor(named: "primaryGrey") ?? .lightGray
        }
    }
    
    var station: String {
        switch self {
        case .current( _, let name):
            return name
        case .normal( _, let name):
            return name
        }
    }
    
    var hour: String {
        switch self {
        case .current(let hour, _):
            return hour
        case .normal(let hour, _):
            return hour
        }
    }
}

class SectionViewModel {
    
    // MARK: - Output
    let fetchSectionResult: Action<Bool, [SectionResult]>
    
    let trainStatus: Driver<String>
    
    let trainNumber: Driver<String>
    
    // MARK: - Initializer
    
    init(travel: Travel) {
        
        self.fetchSectionResult = Action { action -> Observable<[SectionResult]> in
            return TravelTrainAPI
                .trainSections(of: travel.originCode, String(travel.number))
                .map({ sections -> [SectionResult] in
                    return sections.map({ section -> SectionResult in
                        let model = section!
                        
                        let hour = model.departure != 0 ? model.departureHour : model.arrivalHour
                        
                        if model.current {
                            return SectionResult.current(hour: hour, name: model.station)
                        } else {
                            return .normal(hour: hour, name: model.station)
                        }
                        
                    })
                })
                .asObservable()    
        }
        
        self.trainStatus = Observable<String>
            .just(travel.state)
            .asDriver(onErrorJustReturn: "")
        
        self.trainNumber = Observable<String>
            .just(String(travel.category) + " " +  String(travel.number))
            .asDriver(onErrorJustReturn: "")
    }
}
