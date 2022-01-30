//
//  ChatListViewInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import Foundation

protocol ChatListViewInput: AnyObject {
    func showError(error: Error)
    func showLoader()
    func hideLoader()
    func updateChatList(chatModels: [ChatViewModel])
    func showUpdating()
    func hideUpdating()
}
