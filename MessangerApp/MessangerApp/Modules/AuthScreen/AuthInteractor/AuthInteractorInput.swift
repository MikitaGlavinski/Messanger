//
//  AuthInteractorInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import Foundation
import RxSwift

protocol AuthInteractorInput {
    func signInWith(email: String, password: String) -> Single<String>?
    func saveToken(token: String)
}
