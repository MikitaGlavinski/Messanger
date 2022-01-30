//
//  UserStorageAdapter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 26.01.22.
//

import Foundation
import GRDB

struct UserStorageAdapter: Codable, PersistableRecord, FetchableRecord {
    
    static var databaseTableName: String = "UserAdapter"
    
    var id: String
    var email: String
    var imageURL: String
    var chatId: String
    
    init(id: String, email: String, imageURL: String, chatId: String) {
        self.id = id
        self.email = email
        self.imageURL = imageURL
        self.chatId = chatId
    }
    
    init(user: UserModel, chatId: String) {
        self.id = user.id
        self.email = user.email
        self.imageURL = user.imageURL ?? ""
        self.chatId = chatId
    }
}
