//
//  ForwardChatListRouter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/23/22.
//

import UIKit

class ForwardChatListRouter {
    weak var view: UIViewController!
    
    func dismiss() {
        view.dismiss(animated: true, completion: nil)
    }
}
