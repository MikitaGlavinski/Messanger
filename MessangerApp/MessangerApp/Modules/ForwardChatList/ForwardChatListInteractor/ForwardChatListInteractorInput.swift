//
//  ForwardChatListInteractorInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/23/22.
//

import Foundation
import RxSwift

protocol ForwardChatListInteractorInput {
    func getUserToken() -> String?
    func getStoredChats() -> Single<[ChatsStorageResponse]>?
    func signalizeToSend(messageId: String)
    func signalizeChatList()
    func storeMessages(messageAdapters: [MessageStorageAdapter])
    func obtainStoredMessage(with id: String) -> MessageStorageAdapter?
    func obtainStoredChat(with id: String) -> Single<ChatsStorageResponse>?
}
