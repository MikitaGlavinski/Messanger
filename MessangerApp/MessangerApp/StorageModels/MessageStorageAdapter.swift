//
//  MessageStorageAdapter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 26.01.22.
//

import Foundation
import GRDB

struct MessageStorageAdapter: Codable, PersistableRecord, FetchableRecord {
    
    static var databaseTableName: String = "MessageAdapter"
    
    var id: String
    var text: String
    var peerId: String
    var senderId: String
    var chatId: String
    var type: Int
    var fileURL: String
    var date: Double
    var isRead: Bool
    
    init(
        id: String,
        text: String,
        peerId: String,
        senderId: String,
        chatId: String,
        type: Int,
        fileURL: String,
        date: Double,
        isRead: Bool
    ) {
        self.id = id
        self.text = text
        self.peerId = peerId
        self.senderId = senderId
        self.chatId = chatId
        self.type = type
        self.fileURL = fileURL
        self.date = date
        self.isRead = isRead
    }
    
    init(message: MessageModel) {
        self.id = message.id
        self.text = message.text ?? ""
        self.peerId = message.peerId
        self.senderId = message.senderId
        self.chatId = message.chatId
        self.type = message.type
        self.fileURL = message.fileURL ?? ""
        self.date = message.date
        self.isRead = message.isRead
    }
}
