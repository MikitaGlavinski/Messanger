//
//  FirebaseService.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 19.01.22.
//

import UIKit
import RxSwift
import Firebase

protocol FirebaseServiceProtocol {
    func uploadFile(path: String, data: Data, mimeType: String) -> Single<String>
    func deleteFile(at path: String) -> Single<String>
    func addMessagesListener(chatId: String, date: Double, updateClosure: @escaping (Result<[MessageModel], Error>) -> ())
    func addAllMessagesListener(date: Double, updateClosure: @escaping (Result<[MessageModel], Error>) -> ())
    func createUser(user: UserModel) -> Single<UserModel>
    func getUserBy(email: String) -> Single<[UserModel]>
    func getUserBy(token: String) -> Single<UserModel>
    func createChat(chat: ChatModel) -> Single<ChatModel>
    func getChats(userId: String) -> Single<[ChatModel]>
    func getMessages(chatId: String) -> Single<[MessageModel]>
    func addMessage(message: MessageModel) -> Single<MessageModel>
    func getChat(by chatId: String) -> Single<ChatModel>
    func readAllMessages(chatId: String, peerId: String) -> Single<String>
    func deleteMessage(with id: String) -> Single<String>
}

class FirebaseService {
    
    private let db: Firestore
    private let storageRef = Storage.storage().reference()
    
    private let reachabilityService: ReachabilityServiceProtocol
    
    init(reachabilityService: ReachabilityService) {
        self.db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        self.db.settings = settings
        self.reachabilityService = reachabilityService
    }
    
    private func setData<T: Encodable>(at path: String, model: T) -> Single<T> {
        Single<T>.create { [weak self] observer -> Disposable in
            guard let dictionary = try? DictionaryEncoder().encode(value: model) else {
                observer(.failure(NetworkError.decodeError))
                return Disposables.create()
            }
            self?.db.document(path).setData(dictionary) { error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                observer(.success(model))
            }
            return Disposables.create()
        }
    }
    
    private func getData<T: Decodable>(at path: String, decodeType: T.Type) -> Single<T> {
        Single<T>.create { [weak self] observer -> Disposable in
            self?.db.document(path).getDocument(completion: { snapshot, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                guard
                    let data = snapshot?.data(),
                    let model = try? DictionaryDecoder().decode(dictionary: data, decodeType: decodeType)
                else {
                    observer(.failure(NetworkError.decodeError))
                    return
                }
                observer(.success(model))
            })
            return Disposables.create()
        }
    }
    
    private func deleteData(at path: String) -> Single<String> {
        Single<String>.create { [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
            
            if !self.reachabilityService.isReachable() {
                observer(.failure(NetworkError.noConnection))
                return Disposables.create()
            }
            
            self.db.document(path).delete() { error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                observer(.success("Ok"))
            }
            return Disposables.create()
        }
    }
    
    private func getListData<T: Decodable>(at path: String, decodeType: T.Type) -> Single<[T]> {
        Single<[T]>.create { [weak self] observer -> Disposable in
            self?.db.collection(path).getDocuments(completion: { snapshot, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                guard
                    let models = snapshot?.documents.compactMap({try? DictionaryDecoder().decode(dictionary: $0.data(), decodeType: decodeType)})
                else {
                        observer(.failure(NetworkError.decodeError))
                        return
                    }
                observer(.success(models))
            })
            return Disposables.create()
        }
    }
    
    private func getListWithFilterEqual<T: Decodable>(at path: String, field: String, filter: Any, decodeType: T.Type) -> Single<[T]> {
        Single<[T]>.create { [weak self] observer -> Disposable in
            self?.db.collection(path).whereField(field, isEqualTo: filter).getDocuments(completion: { snapshot, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                guard
                    let models = snapshot?.documents.compactMap({try? DictionaryDecoder().decode(dictionary: $0.data(), decodeType: decodeType)})
                else {
                        observer(.failure(NetworkError.decodeError))
                        return
                    }
                observer(.success(models))
            })
            return Disposables.create()
        }
    }
    
    private func getListWithFilterContains<T: Decodable>(at path: String, field: String, filter: Any, decodeType: T.Type) -> Single<[T]> {
        Single<[T]>.create { [weak self] observer -> Disposable in
            self?.db.collection(path).whereField(field, arrayContains: filter).getDocuments(completion: { snapshot, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                guard
                    let models = snapshot?.documents.compactMap({try? DictionaryDecoder().decode(dictionary: $0.data(), decodeType: decodeType)})
                else {
                        observer(.failure(NetworkError.decodeError))
                        return
                    }
                observer(.success(models))
            })
            return Disposables.create()
        }
    }
}

extension FirebaseService: FirebaseServiceProtocol {
    
    func uploadFile(path: String, data: Data, mimeType: String) -> Single<String> {
        Single<String>.create { [weak self] observer -> Disposable in
            guard
                let putRef = self?.storageRef.child(path)
            else {
                observer(.failure(NetworkError.noData))
                return Disposables.create()
            }
            let metadata = StorageMetadata()
            metadata.contentType = mimeType
            putRef.putData(data, metadata: metadata, completion: { metadata, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                putRef.downloadURL { url, error in
                    if let error = error {
                        observer(.failure(error))
                        return
                    }
                    guard let stringURL = url?.absoluteString else {
                        observer(.failure(NetworkError.noData))
                        return
                    }
                    observer(.success(stringURL))
                }
            })
            return Disposables.create()
        }
    }
    
    func deleteFile(at path: String) -> Single<String> {
        Single<String>.create { [weak self] observer -> Disposable in
            guard let deleteRef = self?.storageRef.child(path) else {
                observer(.failure(NetworkError.noData))
                return Disposables.create()
            }
            
            deleteRef.delete { error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                observer(.success("Ok"))
            }
            return Disposables.create()
        }
    }
    
    func addMessagesListener(chatId: String, date: Double, updateClosure: @escaping (Result<[MessageModel], Error>) -> ()) {
        self.db.collection("messages")
            .whereField("chatId", isEqualTo: chatId)
            .whereField("date", isGreaterThan: date)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    updateClosure(.failure(error))
                    return
                }
                if snapshot?.metadata.hasPendingWrites == true {
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let messages = documents.compactMap({try? DictionaryDecoder().decode(dictionary: $0.data(), decodeType: MessageModel.self)})
                updateClosure(.success(messages))
            }
    }
    
    func addAllMessagesListener(date: Double, updateClosure: @escaping (Result<[MessageModel], Error>) -> ()) {
        self.db.collection("messages")
            .whereField("date", isGreaterThan: date)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    updateClosure(.failure(error))
                    return
                }
                if snapshot?.metadata.hasPendingWrites == true {
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let messages = documents.compactMap({try? DictionaryDecoder().decode(dictionary: $0.data(), decodeType: MessageModel.self)})
                updateClosure(.success(messages))
            }
    }
    
    func readAllMessages(chatId: String, peerId: String) -> Single<String> {
        Single<String>.create { [weak self] observer -> Disposable in
            self?.db.collection("messages")
                .whereField("chatId", isEqualTo: chatId)
                .whereField("senderId", isEqualTo: peerId)
                .getDocuments(completion: { snapshot, error in
                    if let error = error {
                        observer(.failure(error))
                        return
                    }
                    guard let documents = snapshot?.documents else {
                        observer(.failure(NetworkError.noData))
                        return
                    }
                    var changeDocumentsCount = 0
                    for document in documents {
                        var dictionary = document.data()
                        dictionary["isRead"] = true
                        document.reference.setData(dictionary) { error in
                            if let error = error {
                                observer(.failure(error))
                                return
                            }
                            changeDocumentsCount += 1
                            if changeDocumentsCount == documents.count {
                                observer(.success("Ok"))
                                return
                            }
                        }
                    }
                })
            return Disposables.create()
        }
    }
    
    func createUser(user: UserModel) -> Single<UserModel> {
        setData(at: "users/\(user.id)", model: user)
    }
    
    func getUserBy(email: String) -> Single<[UserModel]> {
        getListWithFilterEqual(at: "users", field: "email", filter: email, decodeType: UserModel.self)
    }
    
    func getUserBy(token: String) -> Single<UserModel> {
        getData(at: "users/\(token)", decodeType: UserModel.self)
    }
    
    func createChat(chat: ChatModel) -> Single<ChatModel> {
        setData(at: "chats/\(chat.id)", model: chat)
    }
    
    func getChats(userId: String) -> Single<[ChatModel]> {
        getListWithFilterContains(at: "chats", field: "membersIds", filter: userId, decodeType: ChatModel.self)
    }
    
    func getMessages(chatId: String) -> Single<[MessageModel]> {
        getListWithFilterEqual(at: "messages", field: "chatId", filter: chatId, decodeType: MessageModel.self)
    }
    
    func addMessage(message: MessageModel) -> Single<MessageModel> {
        setData(at: "messages/\(message.id)", model: message)
    }
    
    func getChat(by chatId: String) -> Single<ChatModel> {
        getData(at: "chats/\(chatId)", decodeType: ChatModel.self)
    }
    
    func deleteMessage(with id: String) -> Single<String> {
        deleteData(at: "messages/\(id)")
    }
}
