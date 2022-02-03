//
//  ChatPresenterProtocol.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import Foundation

protocol ChatPresenterProtocol {
    func viewDidLoad()
    func addMessagesListener()
    func sendTextMessage(text: String)
}

protocol ChatPresenterInput: AnyObject {
    func updateChat(message: MessageModel)
}
