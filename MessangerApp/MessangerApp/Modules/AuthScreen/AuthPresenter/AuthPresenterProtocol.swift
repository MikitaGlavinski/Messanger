//
//  AuthPresenterProtocol.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import Foundation

protocol AuthPresenterProtocol {
    func signInWith(email: String, password: String)
    func showRegisterScreen()
}
