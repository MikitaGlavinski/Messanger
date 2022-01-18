//
//  RegisterInteractor.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import Foundation
import RxSwift

class RegisterInteractor {
    var authService: AuthServiceProtocol!
    var secureStorage: SecureStorageService!
}

extension RegisterInteractor: RegisterInteractorInput {
    
    func createUser(email: String, password: String) -> Single<String>? {
        authService.createUser(email: email, password: password)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func saveToken(token: String) {
        secureStorage.saveToken(token: token)
    }
}
