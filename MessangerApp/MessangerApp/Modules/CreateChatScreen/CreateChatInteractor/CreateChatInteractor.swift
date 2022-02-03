//
//  CreateChatInteractor.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 24.01.22.
//

import Foundation
import RxSwift

class CreateChatInteractor {
    var secureStorage: SecureStorageServiceProtocol!
    var firebaseService: FirebaseServiceProtocol!
    var chatSignalService: ChatSignalServiceProtocol!
    var storageService: StorageServiceProtocol!
}

extension CreateChatInteractor: CreateChatInteractorInput {
    
    func getToken() -> String? {
        secureStorage.getToken()
    }
    
    func getUser(email: String) -> Single<[UserModel]>? {
        firebaseService.getUserBy(email: email)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func getUser(token: String) -> Single<UserModel>? {
        firebaseService.getUserBy(token: token)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func createChat(chat: ChatModel) -> Single<ChatModel>? {
        firebaseService.createChat(chat: chat)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func signalChatListToUpdate() {
        chatSignalService.signalChatListToUpdate()
    }
    
    func storeChat(chatAdapter: ChatStorageAdapter) {
        storageService.storeChats(chatAdapters: [chatAdapter])
    }
}
