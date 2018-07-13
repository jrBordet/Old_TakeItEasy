//
//  SlideRightTransitionAnimator.swift
//  NavTransition
//
//  Created by Jean Raphael on 01/08/2017.
//  Copyright © 2017 Jean Raphael Bordet. All rights reserved.
//

import UIKit

class SpotlightTransition: NSObject {
    let duration = 0.85
    var isPresenting = false
}

// MARK: - UIViewControllerTransitioningDelegate

extension SpotlightTransition: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        
        guard let revealVC = dismissed as? ListSpotlightViewController else { return nil }
        
        return FlipDismissAnimationController(destinationFrame: CGRect(x: 0, y: 0, width: 320, height: 200), interactionController: revealVC.swipeInteractionController)
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension SpotlightTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else { return }
        
        let container = transitionContext.containerView
        
        let offScreenDown = CGAffineTransform(translationX: 0,
                                              y: container.frame.height)
        
        if isPresenting {
            toView.transform = offScreenDown
        } else {
            container.addSubview(toView)
            container.addSubview(fromView)
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.5, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            //guard self.isPresenting == true else { fromView.transform = offScreenDown; return }
            
            if self.isPresenting == true {
                let snapshotView = fromView.resizableSnapshotView(from: fromView.frame, afterScreenUpdates: true, withCapInsets: .zero)
                snapshotView?.transform = CGAffineTransform(scaleX: 0.95, y: 1)
                snapshotView?.center = CGPoint(x: fromView.center.x, y: fromView.center.y)
                
                container.addSubview(snapshotView!)
                container.addSubview(toView)
                
                toView.transform = CGAffineTransform(translationX: 0,
                                                     y: 40)
            }
            
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
}
