//
//  ChatAssembly.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import UIKit

class ChatAssembly {
    
    static func assemble(chatId: String) -> UIViewController {
        let view = ChatViewController.instantiateWith(storyboard: .main) as! ChatViewController
        let presenter = ChatPresenter(chatId: chatId)
        let interactor = ChatInteractor()
        let router = ChatRouter()
        
        let secureStorage: SecureStorageService? = ServiceLocator.shared.getService()
        let firebaseService: FirebaseService? = ServiceLocator.shared.getService()
        let storageService: StorageService? = ServiceLocator.shared.getService()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.secureStorage = secureStorage
        interactor.firebaseService = firebaseService
        interactor.storageService = storageService
        interactor.presenter = presenter
        router.view = view
        
        return view
    }
}
