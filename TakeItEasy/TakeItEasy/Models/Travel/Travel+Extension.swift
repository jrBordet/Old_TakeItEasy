//
//  Travel+Extension.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 07/06/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import Foundation
import CoreData
import RxDataSources
import RxCoreData

func == (lhs: Travel, rhs: Travel) -> Bool {
    return lhs.number == rhs.number
}

extension Travel: Equatable { }

extension Travel: IdentifiableType {
    typealias Identity = String
    
    var identity: Identity { return String(number) }
}

extension Travel : Persistable {
    typealias T = NSManagedObject
    
    static var entityName: String {
        return "Travel"
    }
    
    static var primaryAttributeName: String {
        return "number"
    }
    
    init(entity: T) {
        number = entity.value(forKey: "number") as! Int
        originCode = entity.value(forKey: "originCode") as! String
        category = entity.value(forKey: "category") as! String
        direction = entity.value(forKey: "direction") as! String
        time = entity.value(forKey: "time") as! String
        state = entity.value(forKey: "state") as! String
        originStation = entity.value(forKey: "originStation") as? String
    }
    
    func update(_ entity: T) {
        entity.setValue(number, forKey: "number")
        entity.setValue(originCode, forKey: "originCode")
        entity.setValue(category, forKey: "category")
        entity.setValue(direction, forKey: "direction")
        entity.setValue(time, forKey: "time")
        entity.setValue(state, forKey: "state")
        entity.setValue(originStation, forKey: "originStation")
        
        do {
            try entity.managedObjectContext?.save()
        } catch let e {
            print(e)
        }
    }
    
}

