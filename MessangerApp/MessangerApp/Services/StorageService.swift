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
    func storeChats(chatAdapters: [ChatStorageAdapter])
    func obtainChats() -> Single<[ChatsStorageResponse]>
    func storeUsers(userAdapters: [UserStorageAdapter])
    func obtainUsers(chatId: String) -> Single<[UserStorageAdapter]>
    func storeMessages(messageAdapters: [MessageStorageAdapter])
    func obtainMessages(chatId: String) -> Single<[MessageStorageAdapter]>
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
        
        migrator.registerMigration("createChatTable") { db in
            if try db.tableExists("ChatAdapter") {
                try db.drop(table: "ChatAdapter")
            }
            
            try db.create(table: "ChatAdapter") { t in
                t.column("id", .text).notNull()
                t.column("membersIds", .text).indexed().notNull()
                t.uniqueKey(["id"], onConflict: .replace)
            }
        }
        
        migrator.registerMigration("createUserTable") { db in
            if try db.tableExists("UserAdapter") {
                try db.drop(table: "UserAdapter")
            }
            
            try db.create(table: "UserAdapter") { t in
                t.column("id", .text).notNull().indexed()
                t.column("email", .text).notNull()
                t.column("imageURL", .text)
                t.column("chatId", .text).notNull().indexed()
                t.uniqueKey(["id", "email"], onConflict: .replace)
            }
        }
        
        migrator.registerMigration("createMessageAdapter") { db in
            if try db.tableExists("MessageAdapter") {
                try db.drop(table: "MessageAdapter")
            }
            
            try db.create(table: "MessageAdapter") { t in
                t.column("id", .text).notNull()
                t.column("text", .text)
                t.column("peerId", .text).notNull().indexed()
                t.column("senderId", .text).notNull().indexed()
                t.column("chatId", .text).notNull().indexed()
                t.column("type", .integer).notNull()
                t.column("fileURL", .text)
                t.column("date", .double).notNull()
                t.column("isRead", .boolean).notNull()
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
    func storeChats(chatAdapters: [ChatStorageAdapter]) {
        do {
            try db.write({ db in
                for chatAdapter in chatAdapters {
                    try chatAdapter.insert(db)
                }
            })
        } catch let error {
            print(error.localizedDescription)
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
                    response.append(ChatsStorageResponse(chats: chat, users: members ?? []))
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
    
    func obtainUsers(chatId: String) -> Single<[UserStorageAdapter]> {
        Single<[UserStorageAdapter]>.create { [weak self] observer -> Disposable in
            do {
                let users = try self?.db.read({ db in
                    try UserStorageAdapter
                        .filter(Column("chatId") == chatId).fetchAll(db)
                })
                observer(.success(users ?? []))
            } catch {
                observer(.success([]))
            }
            return Disposables.create()
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
}
