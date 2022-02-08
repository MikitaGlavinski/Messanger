//
//  ImageRouter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/8/22.
//

import UIKit

class ImageRouter {
    weak var view: UIViewController!
    
    func dismiss() {
        UIView.transition(with: view.view.superview!, duration: 0.25, options: [.transitionCrossDissolve]) {
            self.view.navigationController?.navigationBar.isHidden = false
            self.view.view.removeFromSuperview()
            self.view.removeFromParent()
            self.view.didMove(toParent: nil)
        }
    }
}
