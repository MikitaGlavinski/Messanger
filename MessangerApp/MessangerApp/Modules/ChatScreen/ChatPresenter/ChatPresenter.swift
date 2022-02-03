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
    
    private func updateMessages(messages: [MessageModel]?) {
        if let messages = messages {
            let messageAdapters = messages.compactMap({MessageStorageAdapter(message: $0)})
            interactor.storeMessages(messageAdapters: messageAdapters)
            readMessages()
        }
        guard
            let token = interactor.obtainToken(),
            let storedMessages = interactor.obtainStoredMessages(chatId: chatId)
        else { return }
        storedMessages
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] messages in
                let messageModels = messages.sorted(by: {$0.date > $1.date}).compactMap({MessageViewModel(messageModel: $0, userId: token)})
                self?.view.setupMessages(messages: messageModels)
            }, onFailure: { [weak self] error in
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
    
    private func addMessageListener(after date: Double) {
        interactor.addMessagesListener(chatId: chatId, date: date) { [weak self] result in
            switch result {
            case.success(let messages):
                self?.updateMessages(messages: messages.sorted(by: {$0.date > $1.date}))
            case .failure(let error):
                self?.view.showError(error: error)
            }
        }
    }
    
    private func readMessages() {
        interactor.readAllStoredMessages(chatId: chatId)
        guard
            let peerId = self.peerId,
            let remoteMessageReader = interactor.readAllRemoteMessages(chatId: chatId, peerId: peerId)
        else { return }
        remoteMessageReader
            .subscribe(onSuccess: { [weak self] complete in
                print(complete)
                self?.interactor.signalizeChatList()
            }, onFailure: { error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
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
            let chatObtainer = interactor.obtainChat(chatId: chatId)
        else { return }
        self.senderId = token
        
        storedMessagesObtainer
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] messages -> Single<ChatsStorageResponse> in
                let messageModels = messages.sorted(by: {$0.date > $1.date}).compactMap({MessageViewModel(messageModel: $0, userId: token)})
                self?.view.setupMessages(messages: messageModels)
                return storedChatObtainer
            }
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] response -> Single<ChatModel> in
                self?.view.hideLoader()
                self?.chatModel = ChatModel(chatAdapter: response.chats, userAdapters: response.users)
                let peerUser = response.users.first(where: {$0.id != token})
                self?.peerId = peerUser?.id
                self?.readMessages()
                self?.view.setupChat(peerEmail: peerUser?.email ?? "", peerImageURL: peerUser?.imageURL ?? "")
                return chatObtainer
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] chat in
                self?.view.hideUpdating()
                self?.chatModel = chat
                self?.interactor.storeChats(chats: [ChatStorageAdapter(chat: chat)])
                let peerUser = self?.chatModel?.members.first(where: {$0.id != token})
                self?.peerId = peerUser?.id
                self?.view.setupChat(peerEmail: peerUser?.email ?? "", peerImageURL: peerUser?.imageURL ?? "")
            }, onFailure: { [weak self] error in
                self?.view.hideLoader()
                self?.view.hideUpdating()
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
    
    func addMessagesListener() {
        guard let lastMessageObtainer = interactor.obtainLastMessage(chatId: chatId) else { return }
        lastMessageObtainer
            .subscribe(onSuccess: { [weak self] message in
                self?.addMessageListener(after: message?.date ?? 0)
            }, onFailure: { [weak self] error in
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
    
    func sendTextMessage(text: String) {
        guard
            let peerId = self.peerId,
            let senderId = self.senderId
        else { return }
        let messageAdapter = MessageStorageAdapter(
            id: UUID().uuidString,
            text: text,
            peerId: peerId,
            senderId: senderId,
            chatId: chatId,
            type: 0,
            fileURL: "",
            date: Date().timeIntervalSince1970,
            isRead: false,
            isSent: false
        )
        interactor.storeMessages(messageAdapters: [messageAdapter])
        let viewModel = MessageViewModel(messageModel: messageAdapter, userId: senderId)
        view.addMessage(message: viewModel)
        interactor.signalizeToSend(messageId: messageAdapter.id)
    }
}

extension ChatPresenter: ChatPresenterInput {
    func updateChat(message: MessageModel) {
        guard let senderId = self.senderId else { return }
        let viewMessageModel = MessageViewModel(messageModel: message, userId: senderId)
        self.view.updateMessage(message: viewMessageModel)
    }
}
