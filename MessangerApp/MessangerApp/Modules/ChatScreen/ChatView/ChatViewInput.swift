//
//  ChatViewInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import Foundation

protocol ChatViewInput: AnyObject {
    func showError(error: Error)
    func showLoader()
    func hideLoader()
    func showUpdating()
    func hideUpdating()
    func setupChat(peerEmail: String, peerImageURL: String)
//    func setupMessages(messages: [MessageViewModel])
//    func addMessage(message: MessageViewModel)
//    func updateMessage(message: MessageViewModel)
}
