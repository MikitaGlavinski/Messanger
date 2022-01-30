//
//  ChatViewModel.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 19.01.22.
//

import Foundation

struct ChatViewModel {
    var chatId: String
    var title: String
    var messages: [MessageModel]
    var chatImageURL: String?
    var lastMessageDate: String?
    var lastMessageText: String?
    var unreadMessageCount: Int
    
    init(chat: ChatModel, chatMessages: [MessageModel]?, currentUserId: String) {
        let chatIndex = chat.members.firstIndex(where: {$0.id != currentUserId}) ?? 0
        let filteredMessages = chatMessages?.sorted(by: {$0.date > $1.date})
        self.chatId = chat.id
        self.title = chat.members[chatIndex].email
        self.messages = filteredMessages ?? []
        self.chatImageURL = chat.members[chatIndex].imageURL
        if let doubleDate = filteredMessages?.first?.date {
            self.lastMessageDate = DateFormatterService.shared.formatDate(doubleDate: doubleDate, format: "dd.MM.yy")
        }
        self.unreadMessageCount = chatMessages?.count ?? 0
        lastMessageText = filteredMessages?.first?.text
    }
}
