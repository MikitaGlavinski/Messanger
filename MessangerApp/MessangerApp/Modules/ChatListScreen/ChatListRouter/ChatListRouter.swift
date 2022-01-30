//
//  ChatListRouter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import UIKit

class ChatListRouter {
    weak var view: UIViewController!
    
    func routeToAddChat() {
        let createChatView = CreateChatAssembly.assemble()
        view.navigationController?.pushViewController(createChatView, animated: true)
    }
}
