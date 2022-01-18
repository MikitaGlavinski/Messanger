//
//  AuthInteractor.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import Foundation
import RxSwift

class AuthInteractor {
    var authService: AuthServiceProtocol!
    var secureStorage: SecureStorageServiceProtocol!
}

extension AuthInteractor: AuthInteractorInput {
    
    func signInWith(email: String, password: String) -> Single<String>? {
        authService.signInWith(email: email, password: password)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func saveToken(token: String) {
        secureStorage.saveToken(token: token)
    }
}
