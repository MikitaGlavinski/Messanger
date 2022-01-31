//
//  ChatListPresenterProtocol.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import Foundation

protocol ChatListPresenterProtocol {
    func viewDidLoad()
    func addChat()
    func openChat(with id: String)
}

protocol ChatListPresenterInput: AnyObject {
    func updateChatList()
}
