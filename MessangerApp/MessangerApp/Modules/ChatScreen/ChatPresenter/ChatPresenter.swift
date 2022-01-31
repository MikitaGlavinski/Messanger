//
//  ChatPresenter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import Foundation
import RxSwift

class ChatPresenter {
    weak var view: ChatViewInput!
    var interactor: ChatInteractorInput!
    var router: ChatRouter!
    
    private var chatId: String
    private let disposeBag = DisposeBag()
    
    init(chatId: String) {
        self.chatId = chatId
    }
}

extension ChatPresenter: ChatPresenterProtocol {
    
    func viewDidLoad() {
        view.showLoader()
        view.showUpdating()
        guard
            let token = interactor.obtainToken(),
            let storedMessagesObtainer = interactor.obtainStoredMessages(chatId: chatId),
            let storedChatObtainer = interactor.obtainStoredChat(chatId: chatId),
            let chatObtainer = interactor.obtainChat(chatId: chatId),
            let messagesObtainer = interactor.obtainMessages(chatId: chatId)
        else { return }
        
        var loadedChat: ChatModel!
        storedMessagesObtainer
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] messages -> Single<ChatsStorageResponse> in
                let messageModels = messages.compactMap({MessageViewModel(messageModel: $0, userId: token)})
                self?.view.setupMessages(messages: messageModels)
                return storedChatObtainer
            }
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] response -> Single<ChatModel> in
                self?.view.hideLoader()
                let peerUser = response.users.first(where: {$0.id != token})
                self?.view.setupChat(peerEmail: peerUser?.email ?? "", peerImageURL: peerUser?.imageURL ?? "")
                return chatObtainer
            }
            .flatMap { [weak self] chat -> Single<[MessageModel]> in
                loadedChat = chat
                self?.interactor.storeChats(chats: [ChatStorageAdapter(chat: chat)])
                return messagesObtainer
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] messages in
                self?.view.hideUpdating()
                let peerUser = loadedChat.members.first(where: {$0.id != token})
                let messageModels = messages.compactMap({MessageViewModel(messageModel: $0, userId: token)})
                let messageAdapters = messages.compactMap({MessageStorageAdapter(message: $0)})
                self?.interactor.storeMessages(messageAdapters: messageAdapters)
                self?.view.setupChat(peerEmail: peerUser?.email ?? "", peerImageURL: peerUser?.imageURL ?? "")
                self?.view.setupMessages(messages: messageModels)
            }, onFailure: { [weak self] error in
                self?.view.hideLoader()
                self?.view.hideUpdating()
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
}

extension ChatPresenter: ChatPresenterInput {
    
}
