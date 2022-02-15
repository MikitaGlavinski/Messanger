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
    func setupCollectionView(_ collectionView: UICollectionView)
    func sendTextMessage(text: String)
    func pickPhoto()
    func takePhoto()
    func pickVideo()
    func takeVideo()
}

protocol ChatPresenterInput: AnyObject {
    func updateChat(message: MessageModel)
}
