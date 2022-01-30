//
//  UserModel.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import Foundation

struct UserModel: Codable {
    var id: String
    var email: String
    var imageURL: String?
    
    init(id: String, email: String, imageURL: String?) {
        self.id = id
        self.email = email
        self.imageURL = imageURL
    }
    
    init(userAdapter: UserStorageAdapter) {
        self.id = userAdapter.id
        self.email = userAdapter.email
        self.imageURL = userAdapter.imageURL
    }
}
