//
//  ChatListPresenter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import Foundation
import RxSwift

class ChatListPresenter {
    weak var view: ChatListViewInput!
    var interactor: ChatListInteractorInput!
    var router: ChatListRouter!
    
    private let disposeBag = DisposeBag()
    
    private func storeChats(chats: [ChatModel]) {
        var chatAdapters = [ChatStorageAdapter]()
        var memberAdapters = [UserStorageAdapter]()
        for chat in chats {
            chatAdapters.append(ChatStorageAdapter(chat: chat))
            for member in chat.members {
                memberAdapters.append(UserStorageAdapter(user: member, chatId: chat.id))
            }
        }
        self.interactor.storeChats(chatAdapters: chatAdapters, members: memberAdapters)
    }
    
    private func addMessagesListenerAfter(date: Double) {
        interactor.addMessagesListener(date: date) { [weak self] result in
            switch result {
            case .success(let messages):
                let messageAdapters = messages.compactMap({MessageStorageAdapter(message: $0)})
                self?.interactor.storeMessages(messages: messageAdapters)
                self?.updateChatList()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension ChatListPresenter: ChatListPresenterProtocol {
    
    func viewDidLoad() {
        view.showLoader()
        view.showUpdating()
        guard
            let token = interactor.getUserToken(),
            let storedChatsObtainer = interactor.getStoredChats(),
            let chatsObtainer = interactor.getChatList(userId: token)
        else { return }
        storedChatsObtainer
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] chatsResponse -> Single<[ChatModel]> in
                let chatViewModels = chatsResponse.compactMap({ChatViewModel(chatStorageResponse: $0, currentUserId: token)})
                self?.view.hideLoader()
                self?.view.updateChatList(chatModels: chatViewModels)
                return chatsObtainer
            }
            .flatMap({ [weak self] chats -> Single<[ChatsStorageResponse]> in
                self?.storeChats(chats: chats)
                guard let storedChats = self?.interactor.getStoredChats() else {
                    return Single<[ChatsStorageResponse]>.error(NetworkError.noData)
                }
                return storedChats
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] chats in
                self?.view.hideUpdating()
                let chatViewModels = chats.compactMap({ChatViewModel(chatStorageResponse: $0, currentUserId: token)})
                self?.view.updateChatList(chatModels: chatViewModels)
            }, onFailure: { [weak self] error in
                self?.view.hideLoader()
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
    
    func addMessagesListener() {
        guard let lastMessage = interactor.obtainLastMessage() else { return }
        lastMessage
            .subscribe(onSuccess: { [weak self] message in
                self?.addMessagesListenerAfter(date: message?.date ?? 0)
            }, onFailure: { error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    func addChat() {
        router.routeToAddChat()
    }
    
    func openChat(with id: String) {
        router.routeToChat(id: id)
    }
}

extension ChatListPresenter: ChatListPresenterInput {
    func updateChatList() {
        guard
            let token = interactor.getUserToken(),
            let storedChats = self.interactor.getStoredChats()
        else { return }
        storedChats
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] storedChats in
                let viewModels = storedChats.compactMap({ChatViewModel(chatStorageResponse: $0, currentUserId: token)})
                self?.view.updateChatList(chatModels: viewModels)
            }, onFailure: { error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
}
