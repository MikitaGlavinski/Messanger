//
//  AuthRouter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import UIKit

class AuthRouter {
    
    weak var view: UIViewController!
    
    func routeToChatList() {
        let chatListView = ChatListAssembly.assemble()
        view.navigationController?.setViewControllers([chatListView], animated: true)
    }
    
    func routeToRegister() {
        let registerView = RegisterAssembly.assemble()
        view.navigationController?.pushViewController(registerView, animated: true)
    }
}
