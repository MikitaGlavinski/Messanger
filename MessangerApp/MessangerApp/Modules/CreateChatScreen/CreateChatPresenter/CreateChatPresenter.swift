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
        peerUserObtainer
            .flatMap { models -> Single<UserModel> in
                peerUser = models.first
                return currentUserObtainer
            }
            .flatMap { [weak self] user -> Single<ChatModel> in
                guard let peerUser = peerUser else {
                    return Single<ChatModel>.error(NetworkError.invalidEmail)
                }
                let chatModel = ChatModel(id: UUID().uuidString, members: [user, peerUser], membersIds: [user.id, peerUser.id])
                guard let chatCreator = self?.interactor.createChat(chat: chatModel) else {
                    return Single<ChatModel>.error(NetworkError.requestError)
                }
                return chatCreator
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] chat in
                self?.interactor.storeChat(chatAdapter: ChatStorageAdapter(chat: chat))
                self?.interactor.signalChatListToUpdate()
                self?.view.hideLoader()
                self?.router.dismissView()
            }, onFailure: { [weak self] error in
                self?.view.hideLoader()
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
}
