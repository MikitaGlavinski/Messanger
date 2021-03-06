//
//  MessageModel.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 19.01.22.
//

import Foundation

struct MessageModel: Codable {
    var id: String
    var text: String?
    var peerId: String
    var senderId: String
    var chatId: String
    var type: Int
    var fileURL: String?
    var previewURL: String?
    var date: Double
    var isRead: Bool
    var isSent: Bool
    var previewWidth: Double
    var previewHeight: Double
    
    init(
        id: String,
        text: String? = nil,
        peerId: String,
        senderId: String,
        chatId: String,
        type: Int,
        fileURL: String? = nil,
        previewURL: String? = nil,
        date: Double,
        isRead: Bool,
        isSent: Bool,
        previewWidth: Double,
        previewHeight: Double
    ) {
        self.id = id
        self.text = text
        self.peerId = peerId
        self.senderId = senderId
        self.chatId = chatId
        self.type = type
        self.fileURL = fileURL
        self.previewURL = previewURL
        self.date = date
        self.isRead = isRead
        self.isSent = isSent
        self.previewWidth = previewWidth
        self.previewHeight = previewHeight
    }
    
    init(messageAdapter: MessageStorageAdapter) {
        self.id = messageAdapter.id
        self.text = messageAdapter.text
        self.peerId = messageAdapter.peerId
        self.senderId = messageAdapter.senderId
        self.chatId = messageAdapter.chatId
        self.type = messageAdapter.type
        self.fileURL = messageAdapter.fileURL
        self.previewURL = messageAdapter.previewURL
        self.date = messageAdapter.date
        self.isRead = messageAdapter.isRead
        self.isSent = messageAdapter.isSent
        self.previewWidth = messageAdapter.previewWidth
        self.previewHeight = messageAdapter.previewHeight
    }
}
