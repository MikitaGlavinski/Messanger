//
//  RegisterAssembly.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import UIKit

class RegisterAssembly {
    
    static func assemble() -> UIViewController {
        let view = RegisterViewController.instantiateWith(storyboard: UIStoryboard.main) as! RegisterViewController
        let presenter = RegisterPresenter()
        let interactor = RegisterInteractor()
        let router = RegisterRouter()
        
        let authService: AuthService? = ServiceLocator.shared.getService()
        let secureStorage: SecureStorageService? = ServiceLocator.shared.getService()
        let firebaseService: FirebaseService? = ServiceLocator.shared.getService()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.authService = authService
        interactor.secureStorage = secureStorage
        interactor.firebaseService = firebaseService
        router.view = view
        
        return view
    }
}
