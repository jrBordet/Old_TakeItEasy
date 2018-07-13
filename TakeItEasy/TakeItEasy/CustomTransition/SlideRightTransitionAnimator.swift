//
//  SlideRightTransitionAnimator.swift
//  NavTransition
//
//  Created by Jean Raphael on 01/08/2017.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit

class SlideRightTransitionAnimator: NSObject {
    let duration = 0.5
    
    var isPresenting = false
}

extension SlideRightTransitionAnimator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresenting = true
        
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresenting = false
        
        return self
    }
}

extension SlideRightTransitionAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let container = transitionContext.containerView
        
        if isPresenting {
            container.addSubview(fromView)
            container.addSubview(toView)
        } else {
            container.addSubview(toView)
            container.addSubview(fromView)
        }
        
        let offScreenLeft = CGAffineTransform(translationX: -container.frame.width, y: 0)
       // let offScreenRight = CGAffineTransform(translationX: container.frame.width, y: 0)
        
        if isPresenting {
            toView.transform = offScreenLeft
        }
        
        UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            
            if self.isPresenting {
                toView.transform = CGAffineTransform.identity
            } else {
                fromView.transform = offScreenLeft
            }
            
            
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
}
