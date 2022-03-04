//
//  CreateChatPresenter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 24.01.22.
//

import Foundation
import RxSwift

class CreateChatPresenter {
    weak var view: CreateChatViewInput!
    var interactor: CreateChatInteractorInput!
    var router: CreateChatRouter!
    
    private let disposeBag = DisposeBag()
}

extension CreateChatPresenter: CreateChatPresenterProtocol {
    
    func createChat(userEmail: String) {
        self.view.showLoader()
        guard
            let token = interactor.getToken(),
            let peerUserObtainer = interactor.getUser(email: userEmail),
            let currentUserObtainer = interactor.getUser(token: token)
        else {
            return
        }
        var peerUser: UserModel?
        var senderUser: UserModel?
        peerUserObtainer
            .flatMap { models -> Single<UserModel> in
                peerUser = models.first
                return currentUserObtainer
            }
            .flatMap { [weak self] user -> Single<[ChatModel]> in
                senderUser = user
                guard
                    let peerUser = peerUser,
                    let createdChatObtainer = self?.interactor.getAlreadyCreatedChat(membersIds: [peerUser.id, user.id])
                else {
                    return Single<[ChatModel]>.error(NetworkError.requestError)
                }
                return createdChatObtainer
            }
            .flatMap { [weak self] chats -> Single<ChatModel> in
                if !chats.isEmpty {
                    return Single<ChatModel>.error(NetworkError.chatAlreadyCreated)
                } 
                guard
                    let senderUser = senderUser,
                    let peerUser = peerUser
                else {
                    return Single<ChatModel>.error(NetworkError.requestError)
                }
                
                let chatModel = ChatModel(id: UUID().uuidString, members: [senderUser, peerUser], membersIds: [senderUser.id, peerUser.id])
                guard let chatCreator = self?.interactor.createChat(chat: chatModel) else {
                    return Single<ChatModel>.error(NetworkError.requestError)
                }
                return chatCreator
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] chat in
                self?.view.hideLoader()
                guard
                    let senderUser = senderUser,
                    let peerUser = peerUser
                else { return }
                self?.interactor.storeChat(
                    chatAdapter: ChatStorageAdapter(chat: chat),
                    userAdapters: [
                        UserStorageAdapter(user: senderUser, chatId: chat.id),
                        UserStorageAdapter(user: peerUser, chatId: chat.id)
                    ]
                )
                self?.interactor.signalChatListToUpdate()
                self?.router.dismissView()
            }, onFailure: { [weak self] error in
                self?.view.hideLoader()
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
}
