import RxSwift
import UIKit

protocol SendingServiceProtocol {
    func start(messageId: String?)
}

class SendingService: SendingServiceProtocol {
    private let firebaseService: FirebaseServiceProtocol
    private let storageService: StorageServiceProtocol
    private let chatSignalService: ChatSignalServiceProtocol
    private let dataCacher: DataCacherProtocol
    
    private let disposeBag = DisposeBag()
    private let queue = DispatchQueue(label: "SendingService")
    
    init(
        firebaseService: FirebaseServiceProtocol,
        storageService: StorageServiceProtocol,
        chatSignalService: ChatSignalServiceProtocol,
        dataCacher: DataCacherProtocol
    ) {
        self.firebaseService = firebaseService
        self.storageService = storageService
        self.chatSignalService = chatSignalService
        self.dataCacher = dataCacher
        
        chatSignalService.getStartSendingListener().bind { [weak self] _ in
            self?.start()
        }.disposed(by: disposeBag)
        
        chatSignalService.getSendingMessageListener().bind { [weak self] messageId in
            self?.start(messageId: messageId)
        }.disposed(by: disposeBag)
    }
    
    func start(messageId: String? = nil) {
        queue.async { [weak self] in
            guard let self = self else { return }
            var messageAdapter: MessageStorageAdapter
            if let messageId = messageId {
                guard let message = self.storageService.obtainMessageBy(messageId: messageId) else { return }
                messageAdapter = message
            } else {
                guard let message = self.storageService.obtainFirstSendingMessage() else {
                    self.chatSignalService.signalChatListToUpdate()
                    return
                }
                messageAdapter = message
            }
            
            switch messageAdapter.type {
            case 0:
                self.sendTextMessage(messageAdapter: messageAdapter)
            case 1:
                self.sendImageMessage(messageAdapter: messageAdapter)
            case 2:
                self.sendVideoMessage(messageAdapter: messageAdapter)
            default:
                break
            }
        }
    }
    
    private func sendTextMessage(messageAdapter: MessageStorageAdapter) {
        var messageModel = MessageModel(messageAdapter: messageAdapter)
        messageModel.isSent = true
        let messageSender = firebaseService.addMessage(message: messageModel)
        messageSender
            .subscribe(onSuccess: { [weak self] message in
                self?.storageService.storeMessages(messageAdapters: [MessageStorageAdapter(message: message)])
                self?.chatSignalService.signalChatToUpdate(messageModel: message)
                self?.start()
            }, onFailure: { error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    private func sendImageMessage(messageAdapter: MessageStorageAdapter) {
        let imageURL = dataCacher.obtainFileURL(fileId: messageAdapter.id)
        
        guard let data = try? Data(contentsOf: imageURL) else { return }
        let imageUploader = firebaseService.uploadFile(path: "chat/\(messageAdapter.id)", data: data, mimeType: String.MimeType.image)
        
        imageUploader
            .flatMap { [weak self] imageURL -> Single<MessageModel> in
                var messageModel = MessageModel(messageAdapter: messageAdapter)
                messageModel.isSent = true
                messageModel.fileURL = imageURL
                guard let messageSender = self?.firebaseService.addMessage(message: messageModel) else {
                    return Single<MessageModel>.error(NetworkError.requestError)
                }
                return messageSender
            }
            .subscribe(onSuccess: { [weak self] message in
                self?.storageService.storeMessages(messageAdapters: [MessageStorageAdapter(message: message)])
                self?.chatSignalService.signalChatToUpdate(messageModel: message)
                self?.start()
            }, onFailure: { error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    private func sendVideoMessage(messageAdapter: MessageStorageAdapter) {
        let videoURL = dataCacher.obtainFileURL(fileId: messageAdapter.id)
        let previewURL = dataCacher.obtainFilePreviewURL(fileId: messageAdapter.id)
        
        guard
            let videoData = try? Data(contentsOf: videoURL),
            let previewData = try? Data(contentsOf: previewURL)
        else { return }
        
        let videoUploader = firebaseService.uploadFile(path: "chat/\(messageAdapter.id)", data: videoData, mimeType: String.MimeType.video)
        let previewUploader = firebaseService.uploadFile(path: "chat/preview\(messageAdapter.id)", data: previewData, mimeType: String.MimeType.image)
        var messageModel = MessageModel(messageAdapter: messageAdapter)
        videoUploader
            .flatMap { videoURL -> Single<String> in
                messageModel.fileURL = videoURL
                return previewUploader
            }
            .flatMap { [weak self] previewURL -> Single<MessageModel> in
                messageModel.previewURL = previewURL
                messageModel.isSent = true
                guard let messageSender = self?.firebaseService.addMessage(message: messageModel) else {
                    return Single<MessageModel>.error(NetworkError.requestError)
                }
                return messageSender
            }
            .subscribe(onSuccess: { [weak self] message in
                do {
                    try self?.dataCacher.deleteFileAt(url: videoURL)
                } catch let error {
                    print(error.localizedDescription)
                }
                self?.storageService.storeMessages(messageAdapters: [MessageStorageAdapter(message: message)])
                self?.chatSignalService.signalChatToUpdate(messageModel: message)
                self?.start()
            }, onFailure: { error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
}
