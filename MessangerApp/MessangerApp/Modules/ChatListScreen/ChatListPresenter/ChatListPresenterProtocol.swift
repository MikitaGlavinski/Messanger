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
}

protocol ChatListPresenterInput: AnyObject {
    func updateChatList()
}
