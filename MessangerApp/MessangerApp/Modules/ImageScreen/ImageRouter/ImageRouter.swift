//
//  ImageRouter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/8/22.
//

import UIKit

class ImageRouter {
    weak var view: UIViewController!
    let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    func dismiss() {
        view.view.removeFromSuperview()
        view.removeFromParent()
        view.didMove(toParent: nil)
        completion()
    }
}
