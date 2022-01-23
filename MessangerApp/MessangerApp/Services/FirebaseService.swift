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
    func uploadImage(path: String, image: UIImage) -> Single<String>
    func createUser(user: UserModel) -> Single<String>
}

class FirebaseService {
    
    private let db = Firestore.firestore()
    private let storageRef = Storage.storage().reference()
    
    private func setData<T: Encodable>(at path: String, model: T) -> Single<String> {
        Single<String>.create { [weak self] observer -> Disposable in
            guard let dictionary = try? DictionaryEncoder().encode(value: model) else {
                observer(.failure(NetworkError.decodeError))
                return Disposables.create()
            }
            self?.db.document(path).setData(dictionary) { error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                observer(.success("OK"))
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
}

extension FirebaseService: FirebaseServiceProtocol {
    
    func uploadImage(path: String, image: UIImage) -> Single<String> {
        Single<String>.create { [weak self] observer -> Disposable in
            guard
                let data = image.jpegData(compressionQuality: 0.1),
                let putRef = self?.storageRef.child(path)
            else {
                observer(.failure(NetworkError.noData))
                return Disposables.create()
            }
            putRef.putData(data, metadata: nil, completion: { metadata, error in
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
    
    func createUser(user: UserModel) -> Single<String> {
        setData(at: "users/\(user.id)", model: user)
    }
}
