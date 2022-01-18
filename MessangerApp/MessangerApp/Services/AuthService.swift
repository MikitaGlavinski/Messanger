//
//  AuthService.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import Foundation
import Firebase
import RxSwift

protocol AuthServiceProtocol {
    func signInWith(email: String, password: String) -> Single<String>
    func createUser(email: String, password: String) -> Single<String>
}

class AuthService: AuthServiceProtocol {
    
    func signInWith(email: String, password: String) -> Single<String> {
        Single<String>.create { observer -> Disposable in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                guard let token = authResult?.user.uid else {
                    observer(.failure(NetworkError.noData))
                    return
                }
                observer(.success(token))
            }
            return Disposables.create()
        }
    }
    
    func createUser(email: String, password: String) -> Single<String> {
        Single<String>.create { observer -> Disposable in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                guard let token = authResult?.user.uid else {
                    observer(.failure(NetworkError.noData))
                    return
                }
                observer(.success(token))
            }
            return Disposables.create()
        }
    }
}
