//
//  ForwardChatListAssembly.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/23/22.
//

import UIKit

class ForwardChatListAssembly {
    
    static func assemble(messageId: String) -> UIViewController {
        let view = ForwardChatListViewController.instantiateWith(storyboard: .main) as! ForwardChatListViewController
        let presenter = ForwardChatListPresenter(messageId: messageId)
        let interactor = ForwardChatListInteractor()
        let router = ForwardChatListRouter()
        
        let dataCacher: DataCacher? = ServiceLocator.shared.getService()
        let storageService: StorageService? = ServiceLocator.shared.getService()
        let secureStorage: SecureStorageService? = ServiceLocator.shared.getService()
        let chatSignalService: ChatSignalService? = ServiceLocator.shared.getService()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.dataCacher = dataCacher
        interactor.storageService = storageService
        interactor.secureStorage = secureStorage
        interactor.chatSignalService = chatSignalService
        router.view = view
        
        return view
    }
}
