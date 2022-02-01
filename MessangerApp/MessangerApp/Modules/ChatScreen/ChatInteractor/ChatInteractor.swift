//
//  ChatInteractor.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import Foundation
import RxSwift

class ChatInteractor {
    var secureStorage: SecureStorageServiceProtocol!
    var firebaseService: FirebaseServiceProtocol!
    var storageService: StorageServiceProtocol!
    weak var presenter: ChatPresenterInput!
}

extension ChatInteractor: ChatInteractorInput {
    
    func obtainToken() -> String? {
        secureStorage.getToken()
    }
    
    func obtainStoredMessages(chatId: String) -> Single<[MessageStorageAdapter]>? {
        storageService.obtainMessages(chatId: chatId)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func storeMessages(messageAdapters: [MessageStorageAdapter]) {
        storageService.storeMessages(messageAdapters: messageAdapters)
    }
    
    func obtainMessages(chatId: String) -> Single<[MessageModel]>? {
        firebaseService.getMessages(chatId: chatId)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func sendMessage(message: MessageModel) -> Single<String>? {
        firebaseService.addMessage(message: message)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func obtainStoredChat(chatId: String) -> Single<ChatsStorageResponse>? {
        storageService.obtainChat(chatId: chatId)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func obtainChat(chatId: String) -> Single<ChatModel>? {
        firebaseService.getChat(by: chatId)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func storeChats(chats: [ChatStorageAdapter]) {
        storageService.storeChats(chatAdapters: chats)
    }
    
    func addMessagesListener(chatId: String, updateClosure: @escaping (Result<[MessageModel], Error>) -> ()) {
        firebaseService.addMessagesListener(chatId: chatId, updateClosure: updateClosure)
    }
}
