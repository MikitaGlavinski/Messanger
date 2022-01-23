//
//  RegisterAssembly.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import UIKit

class RegisterAssembly {
    
    static func assemble() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let view = storyboard.instantiateViewController(withIdentifier: "Register") as! RegisterViewController
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
