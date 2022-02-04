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
    var chatImageURL: String?
    var lastMessageDate: String?
    var lastMessageText: String?
    var unreadMessageCount: Int
    
    init(chat: ChatModel, chatMessages: [MessageModel]?, currentUserId: String) {
        let chatIndex = chat.members.firstIndex(where: {$0.id != currentUserId}) ?? 0
        let filteredMessages = chatMessages?.sorted(by: {$0.date < $1.date})
        self.chatId = chat.id
        self.title = chat.members[chatIndex].email
        self.chatImageURL = chat.members[chatIndex].imageURL
        self.unreadMessageCount = chatMessages?.filter({$0.isRead == false && $0.senderId != currentUserId}).count ?? 0
        self.lastMessageText = filteredMessages?.last?.text
        if let doubleDate = filteredMessages?.last?.date {
            self.lastMessageDate = self.dateForChat(doubleDate)
        }
    }
    
    init(chatStorageResponse: ChatsStorageResponse, currentUserId: String) {
        let chatIndex = chatStorageResponse.users.firstIndex(where: {$0.id != currentUserId}) ?? 0
        let filteredMessages = chatStorageResponse.messages.sorted(by: {$0.date < $1.date})
        self.chatId = chatStorageResponse.chats.id
        self.title = chatStorageResponse.users[chatIndex].email
        self.chatImageURL = chatStorageResponse.users[chatIndex].imageURL
        self.unreadMessageCount = chatStorageResponse.messages.filter({$0.isRead == false && $0.senderId != currentUserId}).count
        self.lastMessageText = filteredMessages.last?.text
        if let doubleDate = chatStorageResponse.messages.last?.date {
            self.lastMessageDate = self.dateForChat(doubleDate)
        }
    }
    
    private func dateForChat(_ doubleDate: Double) -> String {
        let date = Date(timeIntervalSince1970: doubleDate)
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return DateFormatterService.shared.formatDate(doubleDate: doubleDate, format: "HH:mm")
        } else if calendar.isDateInWeekend(date) {
            return DateFormatterService.shared.formatDate(doubleDate: doubleDate, format: "E")
        } else {
            return DateFormatterService.shared.formatDate(doubleDate: doubleDate, format: "dd.MM")
        }
    }
}
