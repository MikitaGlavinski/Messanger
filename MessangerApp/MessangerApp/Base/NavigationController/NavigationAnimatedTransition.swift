//
//  NavigationAnimatedTransition.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1.03.22.
//

import UIKit

enum TransitionOperation {
    case push, pop
}

class NavigationAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let operation: TransitionOperation
    
    init(_ operation: TransitionOperation) {
        self.operation = operation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else { return }
        
        let width = fromView.frame.width
        let centerFrame = CGRect(x: 0, y: 0, width: width, height: fromView.frame.height)
        let finalPushFrame = CGRect(x: -width * 0.5, y: 0, width: width, height: fromView.frame.height)
        let finalPopFrame = CGRect(x: width, y: 0, width: width, height: fromView.frame.height)
        
        switch operation {
        case .push:
            transitionContext.containerView.addSubview(toView)
            toView.frame = finalPopFrame
        case .pop:
            transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
            toView.frame = finalPushFrame
            toView.alpha = 0.4
        }
        
        let animations: (() -> Void) = {
            switch self.operation {
            case .push:
                fromView.frame = finalPushFrame
                fromView.alpha = 0.4
            case .pop:
                fromView.frame = finalPopFrame
            }
            toView.frame = centerFrame
            toView.alpha = 1.0
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: animations) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
