//
//  ChatListAssembly.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import UIKit

class ChatListAssembly {
    
    static func assemble() -> UIViewController {
        let firebaseService: FirebaseService? = ServiceLocator.shared.getService()
        let secureStorage: SecureStorageService? = ServiceLocator.shared.getService()
        let chatSignalService: ChatSignalService? = ServiceLocator.shared.getService()
        let storageService: StorageService? = ServiceLocator.shared.getService()
        
        let view = ChatListViewController.instantiateWith(storyboard: UIStoryboard.main) as! ChatListViewController
        let presenter = ChatListPresenter()
        let interactor = ChatListInteractor(chatSignalService: chatSignalService!)
        let router = ChatListRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.firebaseService = firebaseService
        interactor.secureStorage = secureStorage
        interactor.presenter = presenter
        interactor.storageService = storageService
        router.view = view
        
        return view
    }
}
