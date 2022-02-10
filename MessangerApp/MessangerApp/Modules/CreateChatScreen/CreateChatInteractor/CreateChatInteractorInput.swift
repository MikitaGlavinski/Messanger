//
//  CreateChatInteractorInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 24.01.22.
//

import Foundation
import RxSwift

protocol CreateChatInteractorInput {
    func getToken() -> String?
    func getUser(email: String) -> Single<[UserModel]>?
    func getUser(token: String) -> Single<UserModel>?
    func createChat(chat: ChatModel) -> Single<ChatModel>?
    func signalChatListToUpdate()
    func storeChat(chatAdapter: ChatStorageAdapter, userAdapters: [UserStorageAdapter])
}
