//
//  Station+Extensions.swift
//  ViaggioTreno
//
//  Created by Jean Raphael on 30/11/2017.
//  Copyright © 2017 Jean Raphael. All rights reserved.
//

import Foundation
import CoreData
import RxDataSources
import RxCoreData

func == (lhs: Station, rhs: Station) -> Bool {
    return lhs.id == rhs.id
}

extension Station: Equatable { }

extension Station : IdentifiableType {
    typealias Identity = String
    
    var identity: Identity { return id }
}

extension Station: Persistable {
    typealias T = NSManagedObject
    
    static var entityName: String {
        return "Station"
    }
    
    static var primaryAttributeName: String {
        return "id"
    }
    
    init(entity: T) {
        id = entity.value(forKey: "id") as! String
        name = entity.value(forKey: "name") as! String
    }
    
    func update(_ entity: T) {
        entity.setValue(id, forKey: "id")
        entity.setValue(name, forKey: "name")
        
        do {
            try entity.managedObjectContext?.save()
        } catch let e {
            print(e)
        }
    }
    
}
