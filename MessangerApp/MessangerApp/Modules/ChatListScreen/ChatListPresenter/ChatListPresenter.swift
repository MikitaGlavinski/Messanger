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
                let chatModels = chatsResponse.compactMap({ChatModel(chatAdapter: $0.chats, userAdapters: $0.users)})
                let chatViewModels = chatModels.compactMap({ChatViewModel(chat: $0, chatMessages: [], currentUserId: token)})
                self?.view.hideLoader()
                self?.view.updateChatList(chatModels: chatViewModels)
                return chatsObtainer
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] chats in
                let chatViewModels = chats.compactMap({ChatViewModel(chat: $0, chatMessages: [], currentUserId: token)})
                self?.storeChats(chats: chats)
                self?.view.hideUpdating()
                self?.view.updateChatList(chatModels: chatViewModels)
            }, onFailure: { [weak self] error in
                self?.view.hideLoader()
                self?.view.showError(error: error)
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
            let chatsObtainer = interactor.getChatList(userId: token)
        else { return }
        chatsObtainer
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] chats in
                self?.storeChats(chats: chats)
                let viewChatsModels = chats.compactMap({ChatViewModel(chat: $0, chatMessages: [], currentUserId: token)})
                self?.view.updateChatList(chatModels: viewChatsModels)
            }, onFailure: { error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
}
