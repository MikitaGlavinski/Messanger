//
//  ChatListInteractorInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import Foundation
import RxSwift

protocol ChatListInteractorInput {
    func getUserToken() -> String?
    func getChatList(userId: String) -> Single<[ChatModel]>?
    func getStoredChats() -> Single<[ChatsStorageResponse]>?
    func storeChats(chatAdapters: [ChatStorageAdapter], members: [UserStorageAdapter])
    func addMessagesListener(date: Double, updateClosure: @escaping (Result<[MessageModel], Error>) -> ())
    func obtainLastMessage() -> Single<MessageStorageAdapter?>?
    func storeMessages(messages: [MessageStorageAdapter])
}
