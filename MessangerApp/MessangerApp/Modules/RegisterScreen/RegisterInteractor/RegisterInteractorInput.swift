//
//  RegisterInteractorInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import Foundation
import RxSwift

protocol RegisterInteractorInput {
    func createUser(email: String, password: String) -> Single<String>?
    func saveToken(token: String)
}
