//
//  RegisterPresenter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import Foundation
import RxSwift

class RegisterPresenter {
    weak var view: RegisterViewInput!
    var interactor: RegisterInteractorInput!
    var router: RegisterRouter!
    
    private let disposeBag = DisposeBag()
}

extension RegisterPresenter: RegisterPresenterProtocol {
    
    func register(with email: String, password: String) {
        view.showLoader()
        guard let createUser = interactor.createUser(email: email, password: password) else { return }
        createUser
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
}
