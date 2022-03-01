//
//  NavigationTransitionInteractor.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1.03.22.
//

import UIKit

protocol NavigationInteractorProxy {
    var isPerfoming: Bool { get }
}

class NavigationTransitionInteractor: UIPercentDrivenInteractiveTransition, NavigationInteractorProxy {
    private weak var navigationController: UINavigationController?
    private let transitionCompletionThreshold: CGFloat = 0.5
    var completion: (() -> Void)?
    
    var isPerfoming: Bool = false
    
    init?(attachTo viewController: UIViewController) {
        guard let nav = viewController.navigationController else { return nil }
        
        self.navigationController = nav
        super.init()
        setupBackGesture(view: viewController.view)
    }
    
    private func setupBackGesture(view: UIView) {
        let backGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleBackGesture(_:)))
        backGesture.edges = .left
        view.addGestureRecognizer(backGesture)
    }
    
    @objc private func handleBackGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let navigationController = navigationController else { return }
        let translation = gesture.translation(in: gesture.view?.superview)
        let progress = translation.x / navigationController.view.frame.width
        
        switch gesture.state {
        case .began:
            isPerfoming = true
            navigationController.popViewController(animated: true)
        case .changed:
            update(progress)
        case .cancelled:
            isPerfoming = false
            cancel()
        case .ended:
            if gesture.velocity(in: gesture.view).x > 300 {
                finish()
                return
            }
            isPerfoming = false
            progress > transitionCompletionThreshold ? finish() : cancel()
        default:
            return
        }
    }
    
    override func finish() {
        super.finish()
        completion?()
    }
}
