//
//  ForwardChatListInteractor.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/23/22.
//

import Foundation
import RxSwift

class ForwardChatListInteractor {
    var dataCacher: DataCacherProtocol!
    var storageService: StorageServiceProtocol!
    var secureStorage: SecureStorageServiceProtocol!
    var chatSignalService: ChatSignalServiceProtocol!
}

extension ForwardChatListInteractor: ForwardChatListInteractorInput {
    
    func getUserToken() -> String? {
        secureStorage.getToken()
    }
    
    func getStoredChats() -> Single<[ChatsStorageResponse]>? {
        storageService.obtainChats()
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func signalizeToSend(messageId: String) {
        chatSignalService.signalSendMessage(messageId: messageId)
    }
    
    func signalizeChatList() {
        chatSignalService.signalChatListToUpdate()
    }
    
    func storeMessages(messageAdapters: [MessageStorageAdapter]) {
        storageService.storeMessages(messageAdapters: messageAdapters)
    }
    
    func obtainStoredMessage(with id: String) -> MessageStorageAdapter? {
        storageService.obtainMessageBy(messageId: id)
    }
    
    func obtainStoredChat(with id: String) -> Single<ChatsStorageResponse>? {
        storageService.obtainChat(chatId: id)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
}
