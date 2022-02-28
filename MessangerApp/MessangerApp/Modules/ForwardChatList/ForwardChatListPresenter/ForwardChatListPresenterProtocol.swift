//
//  ForwardChatListPresenterProtocol.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/23/22.
//

import Foundation

protocol ForwardChatListPresenterProtocol {
    func viewDidLoad()
    func forwardMessage(chatId: String)
    func hideForwardChatList()
}
