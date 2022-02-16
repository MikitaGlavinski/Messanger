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
    func pickPhoto(sourceType: UIImagePickerController.SourceType)
    func pickVideo(sourceType: UIImagePickerController.SourceType)
}

protocol ChatPresenterInput: AnyObject {
    func updateChat(message: MessageModel)
}
