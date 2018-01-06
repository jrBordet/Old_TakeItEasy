//
//  RootRouter.swift
//  ViaggioTreno
//
//  Created by Jean Raphael on 16/11/2017.
//  Copyright © 2017 Jean Raphael. All rights reserved.
//

import UIKit

struct RootRouter {
    
    static func presentRootViewController(in window: UIWindow) {
        window.makeKeyAndVisible()
                
        window.rootViewController = RouterStation().assembleModule()
    }
    
}
