//
//  ForwardChatListViewInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/23/22.
//

import Foundation

protocol ForwardChatListViewInput: AnyObject {
    func showError(error: Error)
    func setupChats(chatModels: [ChatViewModel])
}
