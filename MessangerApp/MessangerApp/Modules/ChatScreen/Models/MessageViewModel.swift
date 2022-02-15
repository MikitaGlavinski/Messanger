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
    var image: UIImage?
    var localPath: String?
    var date: String
    var doubleDate: Double
    var isOwner: Bool
    var isRead: Bool
    var isSent: Bool
    var previewWidth: CGFloat?
    var previewHeight: CGFloat?
    var cellData: CellData?

    init(messageModel: MessageModel, userId: String) {
        self.id = messageModel.id
        self.text = messageModel.text
        self.peerId = messageModel.peerId
        self.senderId = messageModel.senderId
        self.chatId = messageModel.chatId
        self.fileURL = messageModel.fileURL
        self.isRead = messageModel.isRead
        self.isOwner = messageModel.senderId == userId
        self.date = DateFormatterService.shared.formatDate(doubleDate: messageModel.date, format: "HH:mm")
        self.doubleDate = messageModel.date
        self.type = MessageType(rawValue: messageModel.type) ?? .text
        self.isSent = messageModel.isSent
        self.previewWidth = CGFloat(messageModel.previewWidth)
        self.previewHeight = CGFloat(messageModel.previewHeight)
    }
    
    init(messageModel: MessageStorageAdapter, userId: String) {
        self.id = messageModel.id
        self.text = messageModel.text
        self.peerId = messageModel.peerId
        self.senderId = messageModel.senderId
        self.chatId = messageModel.chatId
        self.fileURL = messageModel.fileURL
        self.localPath = messageModel.localPath
        self.isRead = messageModel.isRead
        self.isOwner = messageModel.senderId == userId
        self.date = DateFormatterService.shared.formatDate(doubleDate: messageModel.date, format: "HH:mm")
        self.doubleDate = messageModel.date
        self.type = MessageType(rawValue: messageModel.type) ?? .text
        self.isSent = messageModel.isSent
        self.previewWidth = CGFloat(messageModel.previewWidth)
        self.previewHeight = CGFloat(messageModel.previewHeight)
    }
    
    func getCollectionCell(from collectionView: UICollectionView, showDate: Bool, indexPath: IndexPath, delegate: MessageActivitiesDelegate?) -> UICollectionViewCell {
        switch self.type {
        case .text:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextMessageCollectionViewCell.reuseIdentifier, for: indexPath) as! TextMessageCollectionViewCell
            cell.configureWithDate = showDate
            cell.configureCell(with: self)
            return cell
        case .image:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageMessageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageMessageCollectionViewCell
            cell.configureWithDate = showDate
            cell.delegate = delegate
            cell.configureCell(with: self)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}
