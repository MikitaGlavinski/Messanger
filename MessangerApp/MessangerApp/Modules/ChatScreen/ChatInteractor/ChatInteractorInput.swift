//
//  ChatInteractorInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import Foundation
import RxSwift

protocol ChatInteractorInput {
    func obtainToken() -> String?
    func obtainStoredMessages(chatId: String) -> Single<[MessageStorageAdapter]>?
    func storeMessages(messageAdapters: [MessageStorageAdapter])
    func obtainMessages(chatId: String) -> Single<[MessageModel]>?
    func sendMessage(message: MessageModel) -> Single<MessageModel>?
    func obtainStoredChat(chatId: String) -> Single<ChatsStorageResponse>?
    func obtainChat(chatId: String) -> Single<ChatModel>?
    func storeChats(chats: [ChatStorageAdapter])
    func addMessagesListener(chatId: String, date: Double, updateClosure: @escaping (Result<[MessageModel], Error>) -> ())
    func obtainLastMessage(chatId: String) -> Single<MessageStorageAdapter?>?
    func signalizeChatList()
    func readAllStoredMessages(chatId: String)
    func readAllRemoteMessages(chatId: String, peerId: String) -> Single<String>?
    func signalizeToSend(messageId: String)
}
