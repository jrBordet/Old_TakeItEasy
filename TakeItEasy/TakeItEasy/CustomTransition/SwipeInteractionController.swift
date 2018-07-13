//
//  SwipeInteractionController.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 10/07/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false
    
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        super.init()
        
        self.viewController = viewController
        
        prepareGestureRecognizer(in: viewController.view)
    }
    
    init(viewController: UIViewController, view: UIView) {
        super.init()
        
        self.viewController = viewController
        
        prepareGestureRecognizer(in: view)
    }
    
    // MARK: - Privates
    
    private func prepareGestureRecognizer(in view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(handleGesture(_:)))
        
        view.addGestureRecognizer(gesture)
    }
    
    // MARK: - Selectors
    
    @objc func handleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.x / 10)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            
            if let vc = viewController as? ListSpotlightViewController {
                vc.searchBar.resignFirstResponder()
            }
            
            viewController.dismiss(animated: true, completion: nil)
            
        case .changed:
            shouldCompleteTransition = progress > 0.5
            update(progress)
            
        case .cancelled:
            interactionInProgress = false
            cancel()
            
        case .ended:
            interactionInProgress = false
            
            if shouldCompleteTransition {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
    
    

}
