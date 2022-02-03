//
//  RegisterInteractorInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import UIKit
import RxSwift

protocol RegisterInteractorInput {
    func createUser(email: String, password: String) -> Single<String>?
    func saveToken(token: String)
    func uploadImage(image: UIImage) -> Single<String>?
    func addUser(user: UserModel) -> Single<UserModel>?
}
