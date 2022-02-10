//
//  StorageService.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 26.01.22.
//

import Foundation
import GRDB
import RxSwift

protocol StorageServiceProtocol {
    func storeChats(chatAdapters: [ChatStorageAdapter], userAdapters: [UserStorageAdapter])
    func obtainChat(chatId: String) -> Single<ChatsStorageResponse>
    func obtainChats() -> Single<[ChatsStorageResponse]>
    func storeUsers(userAdapters: [UserStorageAdapter])
    func storeMessages(messageAdapters: [MessageStorageAdapter])
    func obtainMessages(chatId: String) -> Single<[MessageStorageAdapter]>
    func obtainLastMessage(chatId: String) -> Single<MessageStorageAdapter?>
    func obtainLastMessage() -> Single<MessageStorageAdapter?>
    func readAllMessagesInChat(chatId: String, senderId: String)
    func obtainSendingMessages() -> Single<[MessageStorageAdapter]>
    func obtainFirstSendingMessage() -> MessageStorageAdapter?
    func obtainMessageBy(messageId: String) -> MessageStorageAdapter?
}

class StorageService {
    
    private let db: DatabasePool!
    
    init(path: String) {
        do {
            try db = DatabasePool(path: path)
            try setupTables()
        } catch let error {
            fatalError("\(error.localizedDescription)")
        }
    }
    
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.eraseDatabaseOnSchemaChange = true

        migrator.registerMigration("createChatTable") { db in
            try db.create(table: "ChatAdapter") { t in
                t.column("id", .text).notNull()
                t.column("membersIds", .text).indexed().notNull()
                t.uniqueKey(["id"], onConflict: .replace)
            }
        }

        migrator.registerMigration("createUserTable") { db in
            try db.create(table: "UserAdapter") { t in
                t.column("id", .text).notNull().indexed()
                t.column("email", .text).notNull()
                t.column("imageURL", .text)
                t.column("chatId", .text).notNull().indexed()
                t.uniqueKey(["id", "email"], onConflict: .replace)
            }
        }

        migrator.registerMigration("createMessageAdapter") { db in
            try db.create(table: "MessageAdapter") { t in
                t.column("id", .text).notNull()
                t.column("text", .text)
                t.column("peerId", .text).notNull().indexed()
                t.column("senderId", .text).notNull().indexed()
                t.column("chatId", .text).notNull().indexed()
                t.column("type", .integer).notNull()
                t.column("fileURL", .text)
                t.column("localPath", .text)
                t.column("date", .double).notNull()
                t.column("isRead", .boolean).notNull()
                t.column("isSent", .boolean).notNull()
                t.column("previewWidth", .double)
                t.column("previewHeight", .double)
                t.uniqueKey(["id"], onConflict: .replace)
            }
        }
        
        return migrator
    }
    
    private func setupTables() throws {
        try StorageService.migrator.migrate(db)
    }
}

extension StorageService: StorageServiceProtocol {
    func storeChats(chatAdapters: [ChatStorageAdapter], userAdapters: [UserStorageAdapter]) {
        do {
            try db.write({ db in
                for chatAdapter in chatAdapters {
                    try chatAdapter.insert(db)
                }
                for userAdapter in userAdapters {
                    try userAdapter.insert(db)
                }
            })
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func obtainChat(chatId: String) -> Single<ChatsStorageResponse> {
        Single<ChatsStorageResponse>.create { [weak self] observer -> Disposable in
            do {
                let chat = try self?.db.read({ db in
                    try ChatStorageAdapter
                        .filter(Column("id") == chatId).fetchOne(db)
                })
                let members = try self?.db.read({ db in
                    try UserStorageAdapter
                        .filter(Column("chatId") == chatId).fetchAll(db)
                })
                let messages = try self?.db.read({ db in
                    try MessageStorageAdapter
                        .filter(Column("chatId") == chatId).fetchAll(db)
                })
                guard
                    let chat = chat,
                    let members = members,
                    let messages = messages
                else {
                    return Disposables.create()
                }
                let response = ChatsStorageResponse(chats: chat, users: members, messages: messages)
                observer(.success(response))
            } catch let error {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func obtainChats() -> Single<[ChatsStorageResponse]> {
        Single<[ChatsStorageResponse]>.create { [weak self] observer -> Disposable in
            do {
                let chats = try self?.db.read({ db in
                    try ChatStorageAdapter
                        .fetchAll(db)
                })
                var response = [ChatsStorageResponse]()
                for chat in chats ?? [] {
                    let members = try self?.db.read({ db in
                        try UserStorageAdapter
                            .filter(Column("chatId") == chat.id).fetchAll(db)
                    })
                    let messages = try self?.db.read({ db in
                        try MessageStorageAdapter
                            .filter(Column("chatId") == chat.id).fetchAll(db)
                    })
                    response.append(ChatsStorageResponse(chats: chat, users: members ?? [], messages: messages ?? []))
                }
                observer(.success(response))
            } catch let error {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func storeUsers(userAdapters: [UserStorageAdapter]) {
        do {
            try db.write({ db in
                for userAdapter in userAdapters {
                    try userAdapter.insert(db)
                }
            })
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func storeMessages(messageAdapters: [MessageStorageAdapter]) {
        do {
            try db.write({ db in
                for messageAdapter in messageAdapters {
                    try messageAdapter.insert(db)
                }
            })
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func obtainMessages(chatId: String) -> Single<[MessageStorageAdapter]> {
        Single<[MessageStorageAdapter]>.create { [weak self] observer -> Disposable in
            do {
                let messages = try self?.db.read({ db in
                    try MessageStorageAdapter
                        .filter(Column("chatId") == chatId)
                        .order(Column("date").desc).fetchAll(db)
                })
                observer(.success(messages ?? []))
            } catch {
                observer(.success([]))
            }
            return Disposables.create()
        }
    }
    
    func obtainLastMessage(chatId: String) -> Single<MessageStorageAdapter?> {
        Single<MessageStorageAdapter?>.create { [weak self] observer -> Disposable in
            do {
                let lastMessage = try self?.db.read({ db in
                    try MessageStorageAdapter
                        .filter(Column("chatId") == chatId)
                        .order(Column("date").asc).fetchOne(db)
                })
                guard let lastMessage = lastMessage else {
                    observer(.success(nil))
                    return Disposables.create()
                }
                observer(.success(lastMessage))
            } catch let error {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func obtainLastMessage() -> Single<MessageStorageAdapter?> {
        Single<MessageStorageAdapter?>.create { [weak self] observer -> Disposable in
            do {
                let lastMessage = try self?.db.read({ db in
                    try MessageStorageAdapter
                        .order(Column("date").asc).fetchOne(db)
                })
                guard let lastMessage = lastMessage else {
                    observer(.success(nil))
                    return Disposables.create()
                }
                observer(.success(lastMessage))
            } catch let error {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func readAllMessagesInChat(chatId: String, senderId: String) {
        do {
            let messages = try self.db.read({ db in
                try MessageStorageAdapter
                    .filter(Column("chatId") == chatId)
                    .filter(Column("senderId") == senderId)
                    .filter(Column("isRead") == false).fetchAll(db)
            })
            try self.db.write({ db in
                for var message in messages {
                    message.isRead = true
                    try message.insert(db)
                }
            })
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func obtainSendingMessages() -> Single<[MessageStorageAdapter]> {
        Single<[MessageStorageAdapter]>.create { [weak self] observer -> Disposable in
            do {
                let messages = try self?.db.read({ db in
                    try MessageStorageAdapter
                        .filter(Column("isSent") == false).fetchAll(db)
                })
                observer(.success(messages ?? []))
            } catch let error {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func obtainFirstSendingMessage() -> MessageStorageAdapter? {
        do {
            let message = try self.db.read({ db in
                try MessageStorageAdapter
                    .filter(Column("isSent") == false).fetchOne(db)
            })
            return message
        } catch {
            return nil
        }
    }
    
    func obtainMessageBy(messageId: String) -> MessageStorageAdapter? {
        do {
            let message = try self.db.read({ db in
                try MessageStorageAdapter
                    .filter(Column("id") == messageId).fetchOne(db)
            })
            return message
        } catch {
            return nil
        }
    }
}
