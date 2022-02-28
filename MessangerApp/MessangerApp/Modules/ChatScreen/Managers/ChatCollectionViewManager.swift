//
//  ChatCollectionViewManager.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/10/22.
//

import UIKit

class InvertedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attr = super.layoutAttributesForItem(at: indexPath) else { return nil }
        attr.transform = CGAffineTransform(scaleX: 1, y: -1)
        return attr
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attrList = super.layoutAttributesForElements(in: rect)
        attrList?.forEach({ attr in
            attr.transform = CGAffineTransform(scaleX: 1, y: -1)
        })
        return attrList
    }
}

protocol ChatCollectionViewManagerProtocol {
    func setup(with collectionView: UICollectionView)
    func setupMessages(messages: [MessageViewModel])
    func addMessage(message: MessageViewModel)
    func updateMessage(message: MessageViewModel, withHandle: Bool!)
}

protocol MessageActivitiesDelegate: AnyObject {
    func openImage(with image: UIImage, of imageView: UIImageView)
    func loadImage(with stringURL: String, for message: MessageViewModel)
    func openVideo(with stringURL: String, completion: @escaping () -> Void)
    func deleteMessage(_ message: MessageViewModel)
}

protocol ChatCollectionViewManagerDelegate: AnyObject {
    func openImage(with image: UIImage, superViewImageRect: CGRect, completion: @escaping () -> Void)
    func openVideo(with url: URL)
    func deleteTextMessage(with id: String)
    func deleteImageMessage(with id: String)
    func deleteVideoMessage(with id: String)
    func forwardMessage(messageId: String)
}

class ChatCollectionViewManager: NSObject {
    private var collectionView: UICollectionView!
    private var messages = [MessageViewModel]()
    private weak var delegate: ChatCollectionViewManagerDelegate!
    private let calculateManager = ColculateCellsDataManager()
    private let fileLoader: FileLoaderProtocol!
    
    init(delegate: ChatCollectionViewManagerDelegate, fileLoader: FileLoader? = ServiceLocator.shared.getService()) {
        self.delegate = delegate
        self.fileLoader = fileLoader
    }
}

extension ChatCollectionViewManager: ChatCollectionViewManagerProtocol {
    func setup(with collectionView: UICollectionView) {
        self.collectionView = collectionView
        let layout = InvertedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = .init(width: 1, height: 1)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceVertical = true
        collectionView.register(TextMessageCollectionViewCell.self, forCellWithReuseIdentifier: TextMessageCollectionViewCell.reuseIdentifier)
        collectionView.register(MediaMessageCollectionViewCell.self, forCellWithReuseIdentifier: MediaMessageCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupMessages(messages: [MessageViewModel]) {
        let changeNumber = messages.count - self.messages.count
        let oldMessages = self.messages
        
        calculateManager.handleMessages(messages) { handledMessages in
            self.messages = handledMessages
            if changeNumber > 0 {
                var indexSet = [IndexPath]()
                for item in 0..<changeNumber {
                    indexSet.append(IndexPath(item: item, section: 0))
                }
                self.collectionView.insertItems(at: indexSet)
            } else {
                var forUpdate: Bool = false
                for message in handledMessages {
                    guard let index = oldMessages.firstIndex(where: {$0.id == message.id}) else { return }
                    let oldMessage = oldMessages[index]
                    if oldMessage.isSent != message.isSent || oldMessage.isRead != message.isRead {
                        forUpdate = true
                        self.updateMessage(message: message, withHandle: false)
                    }
                }
                if !forUpdate {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func addMessage(message: MessageViewModel) {
        let lastMessageDate = messages.first?.doubleDate
        calculateManager.handleMessages([message], lastMessageData: lastMessageDate) { messages in
            guard let handledMessage = messages.first else { return }
            self.messages.insert(handledMessage, at: 0)
            self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        }
    }
    
    func updateMessage(message: MessageViewModel, withHandle: Bool! = true) {
        guard let index = messages.firstIndex(where: {$0.id == message.id}) else { return }
        let lastMessageDate = messages.count > 1 ? messages[index + 1].doubleDate : 0
        if !withHandle {
            messages[index] = message
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        } else {
            calculateManager.handleMessages([message], lastMessageData: lastMessageDate) { messages in
                guard let handledMessage = messages.first else { return }
                self.messages[index] = handledMessage
                self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }
}

extension ChatCollectionViewManager: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        let showDate = message.cellData?.showDate ?? false
        let cell = message.getCollectionCell(from: collectionView, showDate: showDate, indexPath: indexPath, delegate: self)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: messages[indexPath.item].cellData?.cellHeight ?? 350)
    }
    
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        let context = UIContextMenuConfiguration(identifier: "\(indexPath.item)" as NSString, previewProvider: nil) { action -> UIMenu? in
//            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), identifier: nil, discoverabilityTitle: nil, state: .off) { _ in
//                let message = self.messages[indexPath.item]
//                self.deleteMessage(message)
//            }
//            
//            let forward = UIAction(title: "Forward", image: UIImage(systemName: "arrowshape.turn.up.forward.fill"), identifier: nil, discoverabilityTitle: nil, state: .off) { _ in
//                let message = self.messages[indexPath.item]
//                self.delegate.forwardMessage(messageId: message.id)
//            }
//            return UIMenu(title: "Options", image: nil, identifier: nil, options: .displayInline, children: [delete, forward])
//        }
//        return context
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//        guard
//            let identifier = configuration.identifier as? String,
//            let index = Int(identifier)
//        else { return nil }
//        
//        let messageType = messages[index].type
//        return messageType == .text ? previewForText(from: configuration, index: index) : previewForImage(from: configuration, index: index)
//    }
//    
//    private func previewForText(from configuration: UIContextMenuConfiguration, index: Int) -> UITargetedPreview? {
//        guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? TextMessageCollectionViewCell else { return nil }
//        
//        let parameters = UIPreviewParameters()
//        parameters.backgroundColor = .clear
//        parameters.visiblePath = UIBezierPath(roundedRect: cell.messageView.bounds, cornerRadius: 15)
//        let targetView = UITargetedPreview(view: cell.messageView, parameters: parameters)
//        return targetView
//    }
//    
//    private func previewForImage(from configuration: UIContextMenuConfiguration, index: Int) -> UITargetedPreview? {
//        guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? MediaMessageCollectionViewCell else { return nil }
//        
//        let parameters = UIPreviewParameters()
//        parameters.backgroundColor = .clear
//        parameters.visiblePath = UIBezierPath(roundedRect: cell.imageView.bounds, cornerRadius: 15)
//        let targetView = UITargetedPreview(view: cell.imageView, parameters: parameters)
//        return targetView
//    }
}

extension ChatCollectionViewManager: MessageActivitiesDelegate {
    func openImage(with image: UIImage, of imageView: UIImageView) {
        guard let superView = collectionView.superview else { return }
        let parentRect = superView.convert(imageView.frame, from: imageView.superview)
        
        let animatedImage = UIImageView()
        animatedImage.contentMode = .scaleAspectFit
        animatedImage.image = image
        animatedImage.frame = parentRect
        animatedImage.layer.cornerRadius = 15
        animatedImage.clipsToBounds = true
        superView.addSubview(animatedImage)
        imageView.image = nil
        
        UIView.animate(withDuration: 0.2) {
            animatedImage.frame = CGRect(x: 0, y: 0, width: superView.frame.width, height: superView.frame.height)
        } completion: { _ in
            self.delegate.openImage(with: image,superViewImageRect: parentRect) {
                imageView.isHidden = false
            }
            imageView.isHidden = true
            imageView.image = image
            animatedImage.removeFromSuperview()
        }
    }
    
    func loadImage(with stringURL: String, for message: MessageViewModel) {
        fileLoader?.fetchImage(with: stringURL, completion: { [weak self] image in
            guard let index = self?.messages.firstIndex(where: {$0.id == message.id}) else { return }
            self?.messages[index].image = image
            self?.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        })
    }
    
    func openVideo(with stringURL: String, completion: @escaping () -> Void) {
        guard let url = URL(string: stringURL) else { return }
        self.delegate.openVideo(with: url)
    }
    
    func deleteMessage(_ message: MessageViewModel) {
        guard let index = messages.firstIndex(where: {$0.id == message.id}) else { return }
        messages.remove(at: index)
        collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        switch message.type {
        case .text  : delegate.deleteTextMessage(with: message.id)
        case .image : delegate.deleteImageMessage(with: message.id)
        case .video : delegate.deleteVideoMessage(with: message.id)
        }
    }
}
