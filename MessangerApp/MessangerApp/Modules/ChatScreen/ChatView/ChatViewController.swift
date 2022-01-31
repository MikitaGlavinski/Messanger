//
//  ChatViewController.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import UIKit
import Kingfisher

class ChatViewController: BaseViewController {
    
    var presenter: ChatPresenterProtocol!
    var messages = [MessageViewModel]() {
        didSet {
            collectionView.reloadData()
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerSendView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var textBackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTitleLabel: UILabel!
    @IBOutlet weak var updatingLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let indexPath = IndexPath(item: messages.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        collectionView.register(TextMessageCollectionViewCell.self, forCellWithReuseIdentifier: TextMessageCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    @IBAction func sendMessage(_ sender: Any) {
    }
    
    @IBAction func addAttachment(_ sender: Any) {
    }
}

extension ChatViewController: ChatViewInput {
    
    func showUpdating() {
        updatingLabel.isHidden = false
    }
    
    func hideUpdating() {
        updatingLabel.isHidden = true
    }
    
    func setupChat(peerEmail: String, peerImageURL: String) {
        chatTitleLabel.text = peerEmail
        userImageButton.kf.setImage(with: URL(string: peerImageURL), for: .normal, placeholder: UIImage.userPlaceholder, options: [.cacheMemoryOnly], completionHandler: nil)
    }
    
    func setupMessages(messages: [MessageViewModel]) {
        self.messages = messages
    }
}

extension ChatViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        return message.getCollectionCell(from: collectionView, indexPath: indexPath)
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    
}
