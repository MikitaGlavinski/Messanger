//
//  NavigationController.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1.03.22.
//

import UIKit

class NavigationController: UINavigationController {
    
    private var interactors: [NavigationInteractorProxy?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension NavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            initializeInteractorFor(toVC)
            return NavigationAnimatedTransition(.push)
        default:
            return NavigationAnimatedTransition(.pop)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        let interactor = interactors.last
        return interactor??.isPerfoming == true ? (interactor as? UIViewControllerInteractiveTransitioning) : nil
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == navigationController.viewControllers.first {
            interactors.removeAll()
        }
    }
    
    private func initializeInteractorFor(_ vc: UIViewController) {
        let interactor = NavigationTransitionInteractor(attachTo: vc)
        interactor?.completion = { [weak self] in
            self?.interactors.removeLast()
        }
        interactors.append(interactor)
    }
}
