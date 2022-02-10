//
//  CreateChatAssembly.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 24.01.22.
//

import UIKit

class CreateChatAssembly {
    
    static func assemble() -> UIViewController {
        let view = CreateChatViewController.instantiateWith(storyboard: UIStoryboard.main) as! CreateChatViewController
        let presenter = CreateChatPresenter()
        let interactor = CreateChatInteractor()
        let router = CreateChatRouter()
        
        let secureStorage: SecureStorageService? = ServiceLocator.shared.getService()
        let firebaseService: FirebaseService? = ServiceLocator.shared.getService()
        let chatSignalService: ChatSignalService? = ServiceLocator.shared.getService()
        let storageService: StorageService? = ServiceLocator.shared.getService()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.secureStorage = secureStorage
        interactor.firebaseService = firebaseService
        interactor.chatSignalService = chatSignalService
        interactor.storageService = storageService
        router.view = view
        
        return view
    }
}
