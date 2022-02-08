import RxSwift
import UIKit

protocol SendingServiceProtocol {
    func start(messageId: String?)
}

class SendingService: SendingServiceProtocol {
    private let firebaseService: FirebaseServiceProtocol
    private let storageService: StorageServiceProtocol
    private let chatSignalService: ChatSignalServiceProtocol
    
    private var sendQueueIds = Set<String>()
    private let disposeBag = DisposeBag()
    private let queue = DispatchQueue(label: "SendingService")
    
    init(
        firebaseService: FirebaseServiceProtocol,
        storageService: StorageServiceProtocol,
        chatSignalService: ChatSignalServiceProtocol
    ) {
        self.firebaseService = firebaseService
        self.storageService = storageService
        self.chatSignalService = chatSignalService
        
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
                    self.sendQueueIds.removeAll()
                    return
                }
                messageAdapter = message
            }
            if self.sendQueueIds.contains(messageAdapter.id) {
                return
            }
            self.sendQueueIds.insert(messageAdapter.id)
            
            switch messageAdapter.type {
            case 0:
                self.sendMessage(messageAdapter: messageAdapter)
            default:
                self.sendMediaMessage(messageAdapter: messageAdapter)
            }
        }
    }
    
    private func sendMessage(messageAdapter: MessageStorageAdapter) {
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
    
    private func sendMediaMessage(messageAdapter: MessageStorageAdapter) {
        let url = URL(fileURLWithPath: messageAdapter.localPath)
        let imageUUID = url.lastPathComponent
        guard
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
        else { return }
        let imageUploader = firebaseService.uploadImage(path: "chat/\(imageUUID)", image: image)
        
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
}
