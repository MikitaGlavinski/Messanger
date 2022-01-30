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
    var date: Double
    var isRead: Bool
}
