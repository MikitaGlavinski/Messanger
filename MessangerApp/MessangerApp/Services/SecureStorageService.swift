//
//  SecureStorageService.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import Foundation

protocol SecureStorageServiceProtocol {
    func saveToken(token: String)
    func getToken() -> String?
}

class SecureStorageService: SecureStorageServiceProtocol {
    
    private let storage = UserDefaults.standard
    
    func saveToken(token: String) {
        storage.setValue(token, forKey: "token")
    }
    
    func getToken() -> String? {
        return storage.string(forKey: "token")
    }
}
