//
//  ForwardChatListPresenter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/23/22.
//

import Foundation
import RxSwift

class ForwardChatListPresenter {
    weak var view: ForwardChatListViewInput!
    var interactor: ForwardChatListInteractorInput!
    var router: ForwardChatListRouter!
    
    private let messageId: String
    private let disposeBag = DisposeBag()
    private var userToken: String?
    
    init(messageId: String) {
        self.messageId = messageId
    }
}

extension ForwardChatListPresenter: ForwardChatListPresenterProtocol {
    
    func viewDidLoad() {
        guard
            let userToken = interactor.getUserToken(),
            let storedChats = interactor.getStoredChats()
        else { return }
        
        self.userToken = userToken
        storedChats
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] chatStorageResponses in
                let chatModels = chatStorageResponses.map({ChatViewModel(chatStorageResponse: $0, currentUserId: userToken)})
                self?.view.setupChats(chatModels: chatModels)
            }, onFailure: { [weak self] error in
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
    
    func forwardMessage(chatId: String) {
        guard
            let senderId = self.userToken,
            let storedChatObtainer = interactor.obtainStoredChat(with: chatId),
            var forwardMessage = interactor.obtainStoredMessage(with: messageId)
        else { return }
        
        storedChatObtainer
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] chatResponse in
                guard let self = self else { return }
                let chatModel = ChatModel(chatAdapter: chatResponse.chats, userAdapters: chatResponse.users)
                let peerId = chatModel.membersIds.first(where: {$0 != senderId})
                
                forwardMessage.id = UUID().uuidString
                forwardMessage.chatId = chatId
                forwardMessage.senderId = senderId
                forwardMessage.peerId = peerId ?? ""
                forwardMessage.isRead = false
                forwardMessage.isSent = false
                forwardMessage.date = Date().timeIntervalSince1970
                
                
                
                self.interactor.storeMessages(messageAdapters: [forwardMessage])
                self.interactor.signalizeToSend(messageId: forwardMessage.id)
                self.interactor.signalizeChatList()
                self.router.dismiss()
            }, onFailure: { [weak self] error in
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
    
    func hideForwardChatList() {
        router.dismiss()
    }
}
