//
//  ChatListInteractor.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import Foundation
import RxSwift

class ChatListInteractor {
    var firebaseService: FirebaseServiceProtocol!
    var secureStorage: SecureStorageServiceProtocol!
    var storageService: StorageServiceProtocol!
    weak var presenter: ChatListPresenterInput!
    
    private let disposeBag = DisposeBag()
    
    init(chatSignalService: ChatSignalServiceProtocol) {
        chatSignalService.getChatListListener().bind { [weak self] _ in
            self?.presenter.updateChatList()
        }.disposed(by: disposeBag)
    }
}

extension ChatListInteractor: ChatListInteractorInput {
    
    func getUserToken() -> String? {
        secureStorage.getToken()
    }
    
    func getChatList(userId: String) -> Single<[ChatModel]>? {
        firebaseService.getChats(userId: userId)
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func getStoredChats() -> Single<[ChatsStorageResponse]>? {
        storageService.obtainChats()
            .subscribe(on: SerialDispatchQueueScheduler(qos: .background))
    }
    
    func storeChats(chatAdapters: [ChatStorageAdapter], members: [UserStorageAdapter]) {
        storageService.storeChats(chatAdapters: chatAdapters)
        storageService.storeUsers(userAdapters: members)
    }
}
