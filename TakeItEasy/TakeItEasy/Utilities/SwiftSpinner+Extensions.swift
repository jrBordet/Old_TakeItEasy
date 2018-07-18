//
//  SwiftSpinner+Extensions.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 23/02/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import Foundation
import SwiftSpinner
import RxSwift
import RxCocoa

extension SwiftSpinner {
    public var rx_progress: AnyObserver<Double> {
        return Binder(self) { spinner, progress in
            let p = max(0, min(progress, 100))
            
            SwiftSpinner.show(delay: p, title: "\(p)%", animated: true)
            }.asObserver()
    }
    
    public var rx_visible: AnyObserver<Bool> {
        return Binder(self) { spinner, value in
            if !value {
                SwiftSpinner.hide()
            }
            }.asObserver()
    }
}
