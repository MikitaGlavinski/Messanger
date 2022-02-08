//
//  ChatPresenterProtocol.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import UIKit

protocol ChatPresenterProtocol {
    func viewDidLoad()
    func addMessagesListener()
    func sendTextMessage(text: String)
    func checkDate(of firstDate: Double, and secondDate: Double) -> Bool
    func pickPhoto()
    func openImage(with image: UIImage)
}

protocol ChatPresenterInput: AnyObject {
    func updateChat(message: MessageModel)
}
