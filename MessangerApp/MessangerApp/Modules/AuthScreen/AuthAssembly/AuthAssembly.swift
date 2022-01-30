//
//  AuthAssembly.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import UIKit

class AuthAssembly {
    
    static func assemble() -> UIViewController {
        let view = AuthViewController.instantiateWith(storyboard: UIStoryboard.main) as! AuthViewController
        let presenter = AuthPresenter()
        let interactor = AuthInteractor()
        let router = AuthRouter()
        
        let authService: AuthService? = ServiceLocator.shared.getService()
        let secureStorage: SecureStorageService? = ServiceLocator.shared.getService()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.authService = authService
        interactor.secureStorage = secureStorage
        router.view = view
        
        return view
    }
}
