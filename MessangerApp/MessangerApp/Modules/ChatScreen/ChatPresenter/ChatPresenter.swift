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
    private var chatModel: ChatModel?
    private var peerId: String?
    private var senderId: String?
    private let disposeBag = DisposeBag()
    
    init(chatId: String) {
        self.chatId = chatId
    }
    
    private func updateMessages(messages: [MessageModel], token: String) {
        let messageModels = messages.compactMap({MessageViewModel(messageModel: $0, userId: token)})
        let messageAdapters = messages.compactMap({MessageStorageAdapter(message: $0)})
        interactor.storeMessages(messageAdapters: messageAdapters)
        view.setupMessages(messages: messageModels)
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
        self.senderId = token
        
        storedMessagesObtainer
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] messages -> Single<ChatsStorageResponse> in
                let messageModels = messages.sorted(by: {$0.date < $1.date}).compactMap({MessageViewModel(messageModel: $0, userId: token)})
                self?.view.setupMessages(messages: messageModels)
                return storedChatObtainer
            }
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] response -> Single<ChatModel> in
                self?.view.hideLoader()
                self?.chatModel = ChatModel(chatAdapter: response.chats, userAdapters: response.users)
                let peerUser = response.users.first(where: {$0.id != token})
                self?.peerId = peerUser?.id
                self?.view.setupChat(peerEmail: peerUser?.email ?? "", peerImageURL: peerUser?.imageURL ?? "")
                return chatObtainer
            }
            .flatMap { [weak self] chat -> Single<[MessageModel]> in
                self?.chatModel = chat
                self?.interactor.storeChats(chats: [ChatStorageAdapter(chat: chat)])
                return messagesObtainer
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] messages in
                self?.view.hideUpdating()
                let peerUser = self?.chatModel?.members.first(where: {$0.id != token})
                self?.peerId = peerUser?.id
                self?.updateMessages(messages: messages.sorted(by: {$0.date < $1.date}), token: token)
                self?.view.setupChat(peerEmail: peerUser?.email ?? "", peerImageURL: peerUser?.imageURL ?? "")
            }, onFailure: { [weak self] error in
                self?.view.hideLoader()
                self?.view.hideUpdating()
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
    
    func addMessagesListener() {
        interactor.addMessagesListener(chatId: chatId) { [weak self] result in
            switch result {
            case.success(let messages):
                guard let token = self?.interactor.obtainToken() else { return }
                self?.updateMessages(messages: messages.sorted(by: {$0.date < $1.date}), token: token)
            case .failure(let error):
                self?.view.showError(error: error)
            }
        }
    }
    
    func sendTextMessage(text: String) {
        guard
            let peerId = self.peerId,
            let senderId = self.senderId
        else { return }
        let messageModel = MessageModel(
            id: UUID().uuidString,
            text: text,
            peerId: peerId,
            senderId: senderId,
            chatId: chatId,
            type: 0,
            fileURL: nil,
            date: Date().timeIntervalSince1970,
            isRead: false
        )
        let messageViewModel = MessageViewModel(messageModel: messageModel, userId: senderId)
        view.addMessage(message: messageViewModel)
        guard let messageSender = interactor.sendMessage(message: messageModel) else { return }
        messageSender
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] response in
                self?.interactor.storeMessages(messageAdapters: [MessageStorageAdapter(message: messageModel)])
                print(response)
            }, onFailure: { [weak self] error in
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
}

extension ChatPresenter: ChatPresenterInput {
    
}
