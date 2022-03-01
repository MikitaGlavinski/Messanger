//
//  ColculateCellsDataManager.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/9/22.
//

import UIKit

class ColculateCellsDataManager {
    
    private let appearance = Appearance()
    private let queue = DispatchQueue(label: "cell.data.calculate", qos: .userInteractive)
    
    func handleMessages(_ messages: [MessageViewModel], lastMessageData: Double? = nil, completion: @escaping ([MessageViewModel]) -> Void) {
        queue.async {
            let handledMessages = messages.compactMap { messageModel -> MessageViewModel? in
                var additionalHeight: CGFloat = self.appearance.additionalHeight
                var configureWithDate: Bool = true
                
                guard let indexPath = messages.firstIndex(where: {$0.id == messageModel.id}) else { return nil }
                let previousMessageDate: Double? = indexPath + 1 != messages.count ? messages[indexPath + 1].doubleDate : nil
                
                if let lastMessageData = lastMessageData {
                    configureWithDate = self.checkDate(of: messageModel.doubleDate, and: lastMessageData)
                    additionalHeight = self.checkDate(of: messageModel.doubleDate, and: lastMessageData) ? self.appearance.additionalHeight : 0
                } else {
                    if let previousMessageDate = previousMessageDate {
                        configureWithDate = self.checkDate(of: messageModel.doubleDate, and: previousMessageDate)
                        additionalHeight = self.checkDate(of: messageModel.doubleDate, and: previousMessageDate) ? self.appearance.additionalHeight : 0
                    }
                }
                
                guard let messageText = messages[indexPath].text, messageText.count > 0 else {
                    let cellHeight = (messageModel.previewHeight ?? 0) + additionalHeight + self.appearance.imageViewYOffset
                    var data = self.handleMediaMessage(with: messageModel, configureWithDate: configureWithDate)
                    data?.cellHeight = cellHeight
                    data?.showDate = configureWithDate
                    var newMessageModel = messageModel
                    newMessageModel.cellData = data
                    return newMessageModel
                }
                
                let textRect = messageText.estimatedSize(width: self.appearance.maxWidth, height: self.appearance.maxHeight, font: UIFont.systemFont(ofSize: 16))
                let cellHeight = textRect.height + self.appearance.textViewYOffset + self.appearance.messageBackViewYOffset + self.appearance.textMessageAdditionalHeight + additionalHeight
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
        
        if !messageModel.isOwner {
            if configureWithDate {
                data.dateLabelFrame = CGRect(
                    x: (UIScreen.main.bounds.width / 2) - (self.appearance.dateWidth / 2),
                    y: self.appearance.dateYOffset,
                    width: self.appearance.dateWidth,
                    height: self.appearance.dateHeight
                )
                data.imageViewFrame = CGRect(
                    x: self.appearance.padding,
                    y: self.appearance.dateYOffset + self.appearance.dateHeight + self.appearance.imageViewYOffset,
                    width: messageModel.previewWidth ?? 0,
                    height: messageModel.previewHeight ?? 0
                )
            } else {
                data.imageViewFrame = CGRect(
                    x: self.appearance.padding,
                    y: self.appearance.imageViewYOffset,
                    width: messageModel.previewWidth ?? 0,
                    height: messageModel.previewHeight ?? 0
                )
            }
            data.timeLabelFrame = CGRect(
                x: data.imageViewFrame.maxX + self.appearance.timePadding,
                y: data.imageViewFrame.maxY - self.appearance.timeHeight,
                width: self.appearance.timeWidth,
                height: self.appearance.timeHeight
            )
            data.isSendStateHidden = true
        } else {
            if configureWithDate {
                data.dateLabelFrame = CGRect(
                    x: (UIScreen.main.bounds.width / 2) - (self.appearance.dateWidth / 2),
                    y: self.appearance.dateYOffset,
                    width: self.appearance.dateWidth,
                    height: self.appearance.dateHeight
                )
                data.imageViewFrame = CGRect(
                    x: UIScreen.main.bounds.width - (messageModel.previewWidth ?? 0) - self.appearance.padding,
                    y: self.appearance.dateYOffset + self.appearance.dateHeight + self.appearance.imageViewYOffset,
                    width: messageModel.previewWidth ?? 0,
                    height: messageModel.previewHeight ?? 0
                )
            } else {
                data.imageViewFrame = CGRect(
                    x: UIScreen.main.bounds.width - (messageModel.previewWidth ?? 0) - self.appearance.padding,
                    y: self.appearance.imageViewYOffset,
                    width: messageModel.previewWidth ?? 0,
                    height: messageModel.previewHeight ?? 0
                )
            }
            data.timeLabelFrame = CGRect(
                x: data.imageViewFrame.minX - self.appearance.timePadding - self.appearance.timeWidth,
                y: data.imageViewFrame.maxY - self.appearance.timeHeight,
                width: self.appearance.timeWidth,
                height: self.appearance.timeHeight
            )
            data.sendStateViewFrame = CGRect(
                x: data.timeLabelFrame.minX - self.appearance.timePadding,
                y: data.imageViewFrame.maxY - self.appearance.sendStateWidthHeight,
                width: self.appearance.sendStateWidthHeight,
                height: self.appearance.sendStateWidthHeight
            )
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
        let textRect = text.estimatedSize(width: self.appearance.maxWidth, height: self.appearance.maxHeight, font: UIFont.systemFont(ofSize: 16))
        if !messageModel.isOwner {
            if configureWithDate {
                data.dateLabelFrame = CGRect(
                    x: (UIScreen.main.bounds.width / 2) - (self.appearance.dateWidth / 2),
                    y: self.appearance.dateYOffset,
                    width: self.appearance.dateWidth,
                    height: self.appearance.dateHeight
                )
                data.textMessageBackViewFrame = CGRect(
                    x: self.appearance.padding,
                    y: self.appearance.dateYOffset + self.appearance.dateHeight + self.appearance.messageBackViewYOffset,
                    width: textRect.width + self.appearance.textViewAdditionalWidth + self.appearance.messageBackViewAdditionalWidth,
                    height: textRect.height + self.appearance.textMessageAdditionalHeight
                )
                data.textViewFrame = CGRect(
                    x: self.appearance.textViewXOffset,
                    y: self.appearance.textViewYOffset,
                    width: textRect.width + self.appearance.textViewAdditionalWidth,
                    height: textRect.height + self.appearance.textMessageAdditionalHeight
                )
            } else {
                data.textMessageBackViewFrame = CGRect(
                    x: self.appearance.padding,
                    y: self.appearance.messageBackViewYOffset,
                    width: textRect.width + self.appearance.padding + self.appearance.messageBackViewAdditionalWidth,
                    height: textRect.height + self.appearance.textMessageAdditionalHeight
                )
                data.textViewFrame = CGRect(
                    x: self.appearance.textViewXOffset,
                    y: self.appearance.textViewYOffset,
                    width: textRect.width + self.appearance.textViewAdditionalWidth,
                    height: textRect.height + self.appearance.textMessageAdditionalHeight
                )
            }
            data.timeLabelFrame = CGRect(
                x: data.textMessageBackViewFrame.maxX + self.appearance.timePadding,
                y: data.textMessageBackViewFrame.maxY - self.appearance.timeHeight,
                width: self.appearance.timeWidth,
                height: self.appearance.timeHeight
            )
            
            data.isSendStateHidden = true
            data.messageBackgroundColor = UIColor.MessengerColors.peerMessageColor
            data.textColor = UIColor.white
        } else {
            if configureWithDate {
                data.dateLabelFrame = CGRect(
                    x: (UIScreen.main.bounds.width / 2) - (self.appearance.dateWidth / 2),
                    y: self.appearance.dateYOffset,
                    width: self.appearance.dateWidth,
                    height: self.appearance.dateHeight
                )
                data.textMessageBackViewFrame = CGRect(
                    x: UIScreen.main.bounds.width - textRect.width - self.appearance.padding - self.appearance.textViewXOffset - self.appearance.textViewAdditionalWidth,
                    y: self.appearance.dateYOffset + self.appearance.dateHeight + self.appearance.messageBackViewYOffset,
                    width: textRect.width + self.appearance.textViewAdditionalWidth + self.appearance.messageBackViewAdditionalWidth,
                    height: textRect.height + self.appearance.textMessageAdditionalHeight
                )
                data.textViewFrame = CGRect(
                    x: self.appearance.textViewXOffset,
                    y: self.appearance.textViewYOffset,
                    width: textRect.width + self.appearance.textViewAdditionalWidth,
                    height: textRect.height + self.appearance.textMessageAdditionalHeight
                )
            } else {
                data.textMessageBackViewFrame = CGRect(
                    x: UIScreen.main.bounds.width - textRect.width - self.appearance.padding - self.appearance.textViewXOffset - self.appearance.textViewAdditionalWidth,
                    y: self.appearance.messageBackViewYOffset,
                    width: textRect.width + self.appearance.textViewAdditionalWidth + self.appearance.messageBackViewAdditionalWidth,
                    height: textRect.height + self.appearance.textMessageAdditionalHeight
                )
                data.textViewFrame = CGRect(
                    x: self.appearance.textViewXOffset,
                    y: self.appearance.textViewYOffset,
                    width: textRect.width + self.appearance.textViewAdditionalWidth,
                    height: textRect.height + self.appearance.textMessageAdditionalHeight
                )
            }
            data.timeLabelFrame = CGRect(
                x: data.textMessageBackViewFrame.minX - self.appearance.timePadding - self.appearance.timeWidth,
                y: data.textMessageBackViewFrame.maxY - self.appearance.timeHeight,
                width: self.appearance.timeWidth,
                height: self.appearance.timeHeight
            )
            data.sendStateViewFrame = CGRect(
                x: data.timeLabelFrame.minX - self.appearance.timePadding,
                y: data.textMessageBackViewFrame.maxY - self.appearance.sendStateWidthHeight,
                width: self.appearance.sendStateWidthHeight,
                height: self.appearance.sendStateWidthHeight
            )
            
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

extension ColculateCellsDataManager {
    struct Appearance {
        let additionalHeight: CGFloat = 22.0
        let padding: CGFloat = 16.0
        let dateYOffset: CGFloat = 7.0
        let dateHeight: CGFloat = 15.0
        let dateWidth: CGFloat = 80.0
        let timePadding: CGFloat = 11.0
        let timeHeight: CGFloat = 10.0
        let timeWidth: CGFloat = 30.0
        let maxWidth: CGFloat = 250.0
        let maxHeight: CGFloat = 2000.0
        let imageViewYOffset: CGFloat = 5.0
        let messageBackViewYOffset: CGFloat = 6.0
        let textViewYOffset: CGFloat = 1.0
        let textMessageAdditionalHeight: CGFloat = 20.0
        let sendStateWidthHeight: CGFloat = 6.0
        let textViewXOffset: CGFloat = 8.0
        let textViewAdditionalWidth: CGFloat = 16.0
        let messageBackViewAdditionalWidth: CGFloat = 11.0
    }
}
