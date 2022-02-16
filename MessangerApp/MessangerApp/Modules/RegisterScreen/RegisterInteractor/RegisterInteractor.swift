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
        guard let data = image.jpegData(compressionQuality: 0.1) else { return nil }
        return firebaseService.uploadFile(path: "avatars/\(UUID().uuidString)", data: data, mimeType: String.MimeType.image)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func addUser(user: UserModel) -> Single<UserModel>? {
        firebaseService.createUser(user: user)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
}
