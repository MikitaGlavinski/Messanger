//
//  ChatAssembly.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import UIKit

class ChatAssembly {
    
    static func assemble() -> UIViewController {
        let view = ChatViewController.instantiateWith(storyboard: .main) as! ChatViewController
        let presenter = ChatPresenter()
        let interactor = ChatInteractor()
        let router = ChatRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        router.view = view
        
        return view
    }
}
