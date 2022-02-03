//
//  ChatSignalService.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 25.01.22.
//

import Foundation
import RxSwift

protocol ChatSignalServiceProtocol {
    func getChatListListener() -> PublishSubject<Void>
    func signalChatListToUpdate()
    func getStartSendingListener() -> PublishSubject<Void>
    func signalStartSending()
    func getSendingMessageListener() -> PublishSubject<String>
    func signalSendMessage(messageId: String)
    func getChatListener() -> PublishSubject<MessageModel>
    func signalChatToUpdate(messageModel: MessageModel)
}

class ChatSignalService {
    let chatListListener: PublishSubject<Void> = PublishSubject<Void>()
    let startSendingListener: PublishSubject<Void> = PublishSubject<Void>()
    let sendingMessageListener: PublishSubject<String> = PublishSubject<String>()
    let chatListener: PublishSubject<MessageModel> = PublishSubject<MessageModel>()
}

extension ChatSignalService: ChatSignalServiceProtocol {
    
    func getChatListListener() -> PublishSubject<Void> {
        return chatListListener
    }
    
    func signalChatListToUpdate() {
        chatListListener.onNext(())
    }
    
    func getStartSendingListener() -> PublishSubject<Void> {
        startSendingListener
    }
    
    func signalStartSending() {
        startSendingListener.onNext(())
    }
    
    func getSendingMessageListener() -> PublishSubject<String> {
        sendingMessageListener
    }
    
    func signalSendMessage(messageId: String) {
        sendingMessageListener.onNext(messageId)
    }
    
    func getChatListener() -> PublishSubject<MessageModel> {
        chatListener
    }
    
    func signalChatToUpdate(messageModel: MessageModel) {
        chatListener.onNext(messageModel)
    }
}
