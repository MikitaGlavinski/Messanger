//
//  ChatPresenter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import RxSwift
import UIKit
import AVFoundation

class ChatPresenter: NSObject {
    weak var view: ChatViewInput!
    var interactor: ChatInteractorInput!
    var router: ChatRouter!
    var collectionManager: ChatCollectionViewManagerProtocol!
    
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
                self?.collectionManager.setupMessages(messages: messageModels)
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
        guard let peerId = self.peerId else { return }
        interactor.readAllStoredMessages(chatId: chatId, senderId: peerId)
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
    
    private func createVideoPreview(from url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        guard let cgImage = try? imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil) else { return nil }
        let image = UIImage(cgImage: cgImage)
        return image
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
                self?.collectionManager.setupMessages(messages: messageModels)
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
                let userAdapters = chat.members.compactMap({UserStorageAdapter(user: $0, chatId: chat.id)})
                self?.chatModel = chat
                self?.interactor.storeChats(chats: [ChatStorageAdapter(chat: chat)], users: userAdapters)
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
    
    func setupCollectionView(_ collectionView: UICollectionView) {
        collectionManager.setup(with: collectionView)
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
            previewURL: "",
            localPath: "",
            date: Date().timeIntervalSince1970,
            isRead: false,
            isSent: false,
            previewWidth: 0.0,
            previewHeight: 0.0
        )
        interactor.storeMessages(messageAdapters: [messageAdapter])
        let viewModel = MessageViewModel(messageModel: messageAdapter, userId: senderId)
        collectionManager.addMessage(message: viewModel)
        interactor.signalizeChatList()
        interactor.signalizeToSend(messageId: messageAdapter.id)
    }
    
    func sendImageMessage(image: UIImage) {
        let imageUUID = UUID().uuidString
        guard
            let peerId = self.peerId,
            let senderId = self.senderId,
            let imageData = image.jpegData(compressionQuality: 0.1),
            let localPath = interactor.cacheOriginalData(imageData, id: imageUUID)
        else { return }
        
        let scaledSize = image.scaledSize(size: CGSize(width: 250, height: 350))
        let messageAdapter = MessageStorageAdapter(
            id: imageUUID,
            text: "",
            peerId: peerId,
            senderId: senderId,
            chatId: self.chatId,
            type: 1,
            fileURL: "",
            previewURL: "",
            localPath: localPath,
            date: Date().timeIntervalSince1970,
            isRead: false,
            isSent: false,
            previewWidth: Double(scaledSize.width),
            previewHeight: Double(scaledSize.height)
        )
        interactor.storeMessages(messageAdapters: [messageAdapter])
        let viewModel = MessageViewModel(messageModel: messageAdapter, userId: senderId)
        collectionManager.addMessage(message: viewModel)
        interactor.signalizeChatList()
        interactor.signalizeToSend(messageId: messageAdapter.id)
    }
    
    func sendVideoMessage(videoURL: URL) {
        let videoUUID = UUID().uuidString
        guard
            let peerId = self.peerId,
            let senderId = self.senderId,
            let videoData = try? Data(contentsOf: videoURL),
            let _ = interactor.cacheOriginalData(videoData, id: videoUUID),
            let previewImage = createVideoPreview(from: videoURL),
            let previewData = previewImage.jpegData(compressionQuality: 0.1),
            let previewLocalPath = interactor.cachePreviewData(previewData, id: videoUUID)
        else { return }
        
        let scaledSize = previewImage.scaledSize(size: CGSize(width: 250, height: 350))
        let messageAdapter = MessageStorageAdapter(
            id: videoUUID,
            text: "",
            peerId: peerId,
            senderId: senderId,
            chatId: self.chatId,
            type: 2,
            fileURL: "",
            previewURL: "",
            localPath: previewLocalPath,
            date: Date().timeIntervalSince1970,
            isRead: false,
            isSent: false,
            previewWidth: Double(scaledSize.width),
            previewHeight: Double(scaledSize.height)
        )
        interactor.storeMessages(messageAdapters: [messageAdapter])
        let viewModel = MessageViewModel(messageModel: messageAdapter, userId: senderId)
        collectionManager.addMessage(message: viewModel)
        interactor.signalizeChatList()
        interactor.signalizeToSend(messageId: messageAdapter.id)
    }
    
    func pickPhoto(sourceType: UIImagePickerController.SourceType) {
        router.getPhoto(sourceType: sourceType, delegate: self)
    }
    
    func pickVideo(sourceType: UIImagePickerController.SourceType) {
        router.getVideo(sourceType: sourceType, delegate: self)
    }
}

extension ChatPresenter: ChatCollectionViewManagerDelegate {
    func openImage(with image: UIImage, superViewImageRect: CGRect, completion: @escaping () -> Void) {
        router.openImageMessage(with: image,superViewImageRect: superViewImageRect, completion: completion)
    }
    
    func openVideo(with url: URL) {
        router.playVideo(with: url)
    }
    
    func deleteTextMessage(with id: String) {
        guard
            let messageDeleter = interactor.deleteMessage(with: id),
            let storedMessage = interactor.obtainStoredMessage(with: id)
        else { return }
        
        self.interactor.deleteStoredMessage(with: id)
        
        messageDeleter
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { complete in
                print(complete)
            }, onFailure: { [weak self] error in
                self?.interactor.storeMessages(messageAdapters: [storedMessage])
                self?.updateMessages(messages: [])
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
    
    func deleteImageMessage(with id: String) {
        guard
            let messageDeleter = interactor.deleteMessage(with: id),
            let imageDeleter = interactor.deleteFile(with: id),
            let storedMessage = interactor.obtainStoredMessage(with: id)
        else { return }
        
        self.interactor.deleteStoredMessage(with: id)
        
        Single.zip(messageDeleter, imageDeleter)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.interactor.deleteFileFromCache(fileId: id)
            }, onFailure: { [weak self] error in
                self?.interactor.storeMessages(messageAdapters: [storedMessage])
                self?.updateMessages(messages: [])
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
    
    func deleteVideoMessage(with id: String) {
        guard
            let messageDeleter = interactor.deleteMessage(with: id),
            let videoDeleter = interactor.deleteFile(with: id),
            let previewDeleter = interactor.deleteFilePreview(with: id),
            let storedMessage = interactor.obtainStoredMessage(with: id)
        else { return }
        
        self.interactor.deleteStoredMessage(with: id)
        
        Single.zip(messageDeleter, videoDeleter, previewDeleter)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.interactor.deleteFileFromCache(fileId: id)
                self?.interactor.deleteFilePreviewFromCache(fileId: id)
            }, onFailure: { [weak self] error in
                self?.interactor.storeMessages(messageAdapters: [storedMessage])
                self?.updateMessages(messages: [])
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
    
    func forwardMessage(messageId: String) {
        router.routeToForwardChatList(messsageId: messageId)
    }
}

extension ChatPresenter: ChatPresenterInput {
    func updateChat(message: MessageModel) {
        guard let senderId = self.senderId else { return }
        let viewMessageModel = MessageViewModel(messageModel: message, userId: senderId)
        collectionManager.updateMessage(message: viewMessageModel, withHandle: true)
    }
}

extension ChatPresenter: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let type = info[.mediaType] as? String {
            if type == "public.image", let image = info[.originalImage] as? UIImage {
                sendImageMessage(image: image)
            } else if type == "public.movie", let videoURL = info[.mediaURL] as? URL {
                sendVideoMessage(videoURL: videoURL)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
