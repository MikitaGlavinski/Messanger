//
//  AuthPresenter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import Foundation
import RxSwift

class AuthPresenter {
    
    weak var view: AuthViewInput!
    var router: AuthRouter!
    var interactor: AuthInteractorInput!
    
    private let disposeBag = DisposeBag()
}

extension AuthPresenter: AuthPresenterProtocol {
    
    func signInWith(email: String, password: String) {
        view.showLoader()
        guard let signIn = interactor.signInWith(email: email, password: password) else { return }
        signIn
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] token in
                self?.view.hideLoader()
                self?.interactor.saveToken(token: token)
                self?.router.routeToChatList()
            }, onFailure: { [weak self] error in
                self?.view.hideLoader()
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
    
    func showRegisterScreen() {
        router.routeToRegister()
    }
}
