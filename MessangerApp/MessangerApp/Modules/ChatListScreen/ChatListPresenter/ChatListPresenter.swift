//
//  ChatListPresenter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import Foundation

class ChatListPresenter {
    weak var view: ChatListViewInput!
    var interactor: ChatListInteractorInput!
    var router: ChatListRouter!
}

extension ChatListPresenter: ChatListPresenterProtocol {
    
}
