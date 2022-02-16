//
//  ColculateCellsDataManager.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/9/22.
//

import UIKit

class ColculateCellsDataManager {
    
    private let queue = DispatchQueue(label: "cell.data.calculate", qos: .userInteractive)
    
    func handleMessages(_ messages: [MessageViewModel], lastMessageData: Double? = nil, completion: @escaping ([MessageViewModel]) -> Void) {
        queue.async {
            let handledMessages = messages.compactMap { messageModel -> MessageViewModel? in
                var additionalHeight: CGFloat = 22
                var configureWithDate: Bool = true
                
                guard let indexPath = messages.firstIndex(where: {$0.id == messageModel.id}) else { return nil }
                let previousMessageDate: Double? = indexPath + 1 != messages.count ? messages[indexPath + 1].doubleDate : nil
                
                if let lastMessageData = lastMessageData {
                    configureWithDate = self.checkDate(of: messageModel.doubleDate, and: lastMessageData)
                    additionalHeight = self.checkDate(of: messageModel.doubleDate, and: lastMessageData) ? 22 : 0
                } else {
                    if let previousMessageDate = previousMessageDate {
                        configureWithDate = self.checkDate(of: messageModel.doubleDate, and: previousMessageDate)
                        additionalHeight = self.checkDate(of: messageModel.doubleDate, and: previousMessageDate) ? 22 : 0
                    }
                }
                
                guard let messageText = messages[indexPath].text, messageText.count > 0 else {
                    let cellHeight = (messageModel.previewHeight ?? 0) + additionalHeight + 5
                    var data = self.handleMediaMessage(with: messageModel, configureWithDate: configureWithDate)
                    data?.cellHeight = cellHeight
                    data?.showDate = configureWithDate
                    var newMessageModel = messageModel
                    newMessageModel.cellData = data
                    return newMessageModel
                }
                
                let textRect = messageText.estimatedSize(width: 250, height: 2000, font: UIFont.systemFont(ofSize: 16))
                let cellHeight = textRect.height + 23 + additionalHeight
                var data = self.handleTextMessage(with: messageModel, configureWithDate: configureWithDate)
                data?.cellHeight = cellHeight
                data?.showDate = configureWithDate
                var newMessageModel = messageModel
                newMessageModel.cellData = data
                
                return newMessageModel
            }
            DispatchQueue.main.async {
                completion(handledMessages)
            }
        }
    }
    
    private func handleMediaMessage(with messageModel: MessageViewModel, configureWithDate: Bool) -> ImageCellData? {
        var data = ImageCellData()
        data.timeLabelText = messageModel.date

        if configureWithDate {
            data.dateLabelText = DateFormatterService.shared.formatDate(doubleDate: messageModel.doubleDate, format: "dd.MM.yy")
        }

        let paddingNumber: CGFloat = 16
        if !messageModel.isOwner {
            if configureWithDate {
                data.dateLabelFrame = CGRect(x: (UIScreen.main.bounds.width / 2) - 40, y: 7, width: 80, height: 15)
                data.imageViewFrame = CGRect(x: paddingNumber + 3, y: 27, width: messageModel.previewWidth ?? 0, height: messageModel.previewHeight ?? 0)
            } else {
                data.imageViewFrame = CGRect(x: paddingNumber + 3, y: 5, width: messageModel.previewWidth ?? 0, height: messageModel.previewHeight ?? 0)
            }
            data.timeLabelFrame = CGRect(x: data.imageViewFrame.maxX + 11, y: data.imageViewFrame.maxY - 10, width: 30, height: 10)
            data.isSendStateHidden = true
        } else {
            if configureWithDate {
                data.dateLabelFrame = CGRect(x: (UIScreen.main.bounds.width / 2) - 40, y: 7, width: 80, height: 15)
                data.imageViewFrame = CGRect(x: UIScreen.main.bounds.width - (messageModel.previewWidth ?? 0) - paddingNumber + 3, y: 33, width: messageModel.previewWidth ?? 0, height: messageModel.previewHeight ?? 0)
            } else {
                data.imageViewFrame = CGRect(x: UIScreen.main.bounds.width - (messageModel.previewWidth ?? 0) - paddingNumber + 3, y: 10, width: messageModel.previewWidth ?? 0, height: messageModel.previewHeight ?? 0)
            }
            data.timeLabelFrame = CGRect(x: data.imageViewFrame.minX - 11 - 25, y: data.imageViewFrame.maxY - 10, width: 30, height: 10)
            data.sendStateViewFrame = CGRect(x: data.timeLabelFrame.minX - 11, y: data.imageViewFrame.maxY - 6, width: 6, height: 6)
        }
        data.sendStateViewBorderColor = messageModel.isSent ? UIColor.MessengerColors.ownerMessageColor.cgColor : UIColor.systemRed.cgColor
        data.sendStateViewBackgroundColor = messageModel.isRead ? UIColor.MessengerColors.ownerMessageColor : .clear
        return data
    }
    
    private func handleTextMessage(with messageModel: MessageViewModel, configureWithDate: Bool) -> TextCellData? {
        var data = TextCellData()
        data.timeLabelText = messageModel.date
        
        if configureWithDate {
            data.dateLabelText = DateFormatterService.shared.formatDate(doubleDate: messageModel.doubleDate, format: "dd.MM.yy")
        }
        
        guard let text = messageModel.text else { return nil }
        let paddingNumber: CGFloat = 16
        let textRect = text.estimatedSize(width: 250, height: 2000, font: UIFont.systemFont(ofSize: 16))
        if !messageModel.isOwner {
            if configureWithDate {
                data.dateLabelFrame = CGRect(x: (UIScreen.main.bounds.width / 2) - 40, y: 7, width: 80, height: 15)
                data.textMessageBackViewFrame = CGRect(x: paddingNumber, y: 25, width: textRect.width + 16 + 11, height: textRect.height + 20)
                data.textViewFrame = CGRect(x: paddingNumber + 8, y: 26, width: textRect.width + 16, height: textRect.height + 20)
            } else {
                data.textMessageBackViewFrame = CGRect(x: paddingNumber, y: 2, width: textRect.width + 16 + 11, height: textRect.height + 20)
                data.textViewFrame = CGRect(x: paddingNumber + 8, y: 3, width: textRect.width + 16, height: textRect.height + 20)
            }
            data.timeLabelFrame = CGRect(x: data.textMessageBackViewFrame.maxX + 11, y: data.textMessageBackViewFrame.maxY - 10, width: 30, height: 10)
            
            data.isSendStateHidden = true
            data.messageBackgroundColor = UIColor.MessengerColors.peerMessageColor
            data.textColor = UIColor.white
        } else {
            if configureWithDate {
                data.dateLabelFrame = CGRect(x: (UIScreen.main.bounds.width / 2) - 40, y: 7, width: 80, height: 15)
                data.textMessageBackViewFrame = CGRect(x: UIScreen.main.bounds.width - textRect.width - paddingNumber - 8 - 16, y: 25, width: textRect.width + 16 + 11, height: textRect.height + 20)
                data.textViewFrame = CGRect(x: UIScreen.main.bounds.width - textRect.width - paddingNumber - 16, y: 26, width: textRect.width + 16, height: textRect.height + 20)
            } else {
                data.textMessageBackViewFrame = CGRect(x: UIScreen.main.bounds.width - textRect.width - paddingNumber - 8 - 16, y: 2, width: textRect.width + 16 + 11, height: textRect.height + 20)
                data.textViewFrame = CGRect(x: UIScreen.main.bounds.width - textRect.width - paddingNumber - 16, y: 3, width: textRect.width + 16, height: textRect.height + 20)
            }
            data.timeLabelFrame = CGRect(x: data.textMessageBackViewFrame.minX - 11 - 25, y: data.textMessageBackViewFrame.maxY - 10, width: 30, height: 10)
            data.sendStateViewFrame = CGRect(x: data.timeLabelFrame.minX - 11, y: data.textMessageBackViewFrame.maxY - 6, width: 6, height: 6)
            
            data.messageBackgroundColor = UIColor.MessengerColors.ownerMessageColor
            data.textColor = UIColor.white
        }
        data.textContainsOnlyEmoji = text.containsOnlyEmoji
        data.sendStateViewBorderColor = messageModel.isSent ? UIColor.MessengerColors.ownerMessageColor.cgColor : UIColor.systemRed.cgColor
        data.sendStateViewBackgroundColor = messageModel.isRead ? UIColor.MessengerColors.ownerMessageColor : .clear
        return data
    }
    
    private func checkDate(of firstDate: Double, and secondDate: Double) -> Bool {
        let calendar = Calendar.current
        let isInSameDay = calendar.isDate(Date(timeIntervalSince1970: firstDate), inSameDayAs: Date(timeIntervalSince1970: secondDate))
        return !isInSameDay
    }
}
