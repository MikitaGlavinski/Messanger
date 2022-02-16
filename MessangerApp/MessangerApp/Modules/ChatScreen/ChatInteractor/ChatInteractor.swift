//
//  ChatInteractor.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import RxSwift
import UIKit

class ChatInteractor {
    var secureStorage: SecureStorageServiceProtocol!
    var firebaseService: FirebaseServiceProtocol!
    var storageService: StorageServiceProtocol!
    var chatSignalService: ChatSignalServiceProtocol!
    var dataCacher: DataCacherProtocol!
    weak var presenter: ChatPresenterInput!
    
    private let disposeBag = DisposeBag()
    
    init(chatSignalService: ChatSignalServiceProtocol?) {
        self.chatSignalService = chatSignalService
        
        chatSignalService?.getChatListener().bind(onNext: { [weak self] message in
            self?.presenter.updateChat(message: message)
        }).disposed(by: disposeBag)
    }
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
    
    func sendMessage(message: MessageModel) -> Single<MessageModel>? {
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
    
    func storeChats(chats: [ChatStorageAdapter], users: [UserStorageAdapter]) {
        storageService.storeChats(chatAdapters: chats, userAdapters: users)
    }
    
    func addMessagesListener(chatId: String, date: Double, updateClosure: @escaping (Result<[MessageModel], Error>) -> ()) {
        firebaseService.addMessagesListener(chatId: chatId, date: date, updateClosure: updateClosure)
    }
    
    func obtainLastMessage(chatId: String) -> Single<MessageStorageAdapter?>? {
        storageService.obtainLastMessage(chatId: chatId)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func signalizeChatList() {
        chatSignalService.signalChatListToUpdate()
    }
    
    func readAllStoredMessages(chatId: String, senderId: String) {
        storageService.readAllMessagesInChat(chatId: chatId, senderId: senderId)
    }
    
    func readAllRemoteMessages(chatId: String, peerId: String) -> Single<String>? {
        firebaseService.readAllMessages(chatId: chatId, peerId: peerId)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func signalizeToSend(messageId: String) {
        chatSignalService.signalSendMessage(messageId: messageId)
    }
    
    func cacheOriginalData(_ data: Data, id: String) -> String? {
        return dataCacher.cacheOriginalData(data, id: id)
    }
    
    func cachePreviewData(_ data: Data, id: String) -> String? {
        return dataCacher.cacheDataPreview(data, id: id)
    }
}
