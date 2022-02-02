//
//  ChatStorageAdapter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 26.01.22.
//

import Foundation
import GRDB

struct ChatsStorageResponse {
    var chats: ChatStorageAdapter
    var users: [UserStorageAdapter]
    var messages: [MessageStorageAdapter]
}

struct ChatStorageAdapter: Codable, PersistableRecord, FetchableRecord {
    
    static let databaseTableName: String = "ChatAdapter"
    
    var id: String
    var membersIds: String
    
    init(id: String, membersIds: String) {
        self.id = id
        self.membersIds = membersIds
    }
    
    init(chat: ChatModel) {
        self.id = chat.id
        self.membersIds = chat.membersIds.joined(separator: ",")
    }
}
