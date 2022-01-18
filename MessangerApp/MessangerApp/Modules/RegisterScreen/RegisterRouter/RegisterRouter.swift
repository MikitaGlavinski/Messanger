//
//  RegisterRouter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import UIKit

class RegisterRouter {
    weak var view: UIViewController!
    
    func routeToChatList() {
        let chatListView = ChatListAssembly.assemble()
        view.navigationController?.setViewControllers([chatListView], animated: true)
    }
}
