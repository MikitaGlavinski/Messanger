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
        dataCacher.cacheOriginalData(data, id: id)
    }
    
    func cachePreviewData(_ data: Data, id: String) -> String? {
        dataCacher.cacheDataPreview(data, id: id)
    }
    
    func deleteMessage(with id: String) -> Single<String>? {
        firebaseService.deleteMessage(with: id)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func deleteStoredMessage(with id: String) {
        storageService.deleteMessage(messageId: id)
    }
    
    func obtainStoredMessage(with id: String) -> MessageStorageAdapter? {
        storageService.obtainMessageBy(messageId: id)
    }
    
    func deleteFileFromCache(fileId: String) {
        let fileURL = dataCacher.obtainFileURL(fileId: fileId)
        do {
            try dataCacher.deleteFileAt(url: fileURL)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func deleteFilePreviewFromCache(fileId: String) {
        let fileURL = dataCacher.obtainFilePreviewURL(fileId: fileId)
        do {
            try dataCacher.deleteFileAt(url: fileURL)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func deleteFile(with id: String) -> Single<String>? {
        firebaseService.deleteFile(at: "chat/\(id)")
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func deleteFilePreview(with id: String) -> Single<String>? {
        firebaseService.deleteFile(at: "chat/preview\(id)")
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
}
