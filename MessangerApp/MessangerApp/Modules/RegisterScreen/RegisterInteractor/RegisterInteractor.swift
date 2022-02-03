//
//  RegisterInteractor.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import Foundation
import RxSwift
import UIKit

class RegisterInteractor {
    var authService: AuthServiceProtocol!
    var secureStorage: SecureStorageService!
    var firebaseService: FirebaseServiceProtocol!
}

extension RegisterInteractor: RegisterInteractorInput {
    
    func createUser(email: String, password: String) -> Single<String>? {
        authService.createUser(email: email, password: password)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func saveToken(token: String) {
        secureStorage.saveToken(token: token)
    }
    
    func uploadImage(image: UIImage) -> Single<String>? {
        firebaseService.uploadImage(path: "avatars/\(UUID().uuidString)", image: image)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func addUser(user: UserModel) -> Single<UserModel>? {
        firebaseService.createUser(user: user)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
}
