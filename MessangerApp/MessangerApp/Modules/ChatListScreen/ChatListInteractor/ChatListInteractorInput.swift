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
}
