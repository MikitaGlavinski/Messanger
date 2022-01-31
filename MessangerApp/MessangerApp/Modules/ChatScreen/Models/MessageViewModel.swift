//
//  MessageViewModel.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/31/22.
//

import UIKit

enum MessageType: Int {
    case text, image, video
}

struct MessageViewModel {
    var id: String
    var text: String?
    var peerId: String
    var senderId: String
    var chatId: String
    var type: MessageType
    var fileURL: String?
    var date: String
    var isOwner: Bool
    var isRead: Bool
    
    init(messageModel: MessageModel, userId: String) {
        self.id = messageModel.id
        self.text = messageModel.text
        self.peerId = messageModel.peerId
        self.senderId = messageModel.senderId
        self.chatId = messageModel.chatId
        self.fileURL = messageModel.fileURL
        self.isRead = messageModel.isRead
        self.isOwner = messageModel.senderId == userId
        self.date = DateFormatterService.shared.formatDate(doubleDate: messageModel.date, format: "dd MM, HH:mm")
        self.type = MessageType(rawValue: messageModel.type) ?? .text
    }
    
    init(messageModel: MessageStorageAdapter, userId: String) {
        self.id = messageModel.id
        self.text = messageModel.text
        self.peerId = messageModel.peerId
        self.senderId = messageModel.senderId
        self.chatId = messageModel.chatId
        self.fileURL = messageModel.fileURL
        self.isRead = messageModel.isRead
        self.isOwner = messageModel.senderId == userId
        self.date = DateFormatterService.shared.formatDate(doubleDate: messageModel.date, format: "dd MM, HH:mm")
        self.type = MessageType(rawValue: messageModel.type) ?? .text
    }
    
    func getCollectionCell(from collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        switch self.type {
        case .text:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextMessageCollectionViewCell.reuseIdentifier, for: indexPath) as! TextMessageCollectionViewCell
            cell.configureCell(with: self)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}
