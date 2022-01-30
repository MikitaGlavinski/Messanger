//
//  ChatSignalService.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 25.01.22.
//

import Foundation
import RxSwift

protocol ChatSignalServiceProtocol {
    func getChatListListener() -> PublishSubject<Void>
    func signalChatListToUpdate()
}

class ChatSignalService {
    let chatListListener: PublishSubject<Void> = PublishSubject<Void>()
}

extension ChatSignalService: ChatSignalServiceProtocol {
    
    func getChatListListener() -> PublishSubject<Void> {
        return chatListListener
    }
    
    func signalChatListToUpdate() {
        chatListListener.onNext(())
    }
}
