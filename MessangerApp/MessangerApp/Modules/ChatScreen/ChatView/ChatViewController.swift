//
//  ChatViewController.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift

class ChatViewController: BaseViewController {
    
    var presenter: ChatPresenterProtocol!
    var messages = [MessageViewModel]()
    private let disposeBag = DisposeBag()

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerSendView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textBackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTitleLabel: UILabel!
    @IBOutlet weak var updatingLabel: UILabel!
    
    private lazy var userImageButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.clipsToBounds = true
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        collectionView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        presenter.addMessagesListener()
        setupUI()
        setupGestures()
    }
    
    private func setupUI() {
        messageTextView.delegate = self
        collectionView.register(TextMessageCollectionViewCell.self, forCellWithReuseIdentifier: TextMessageCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let barButton = UIBarButtonItem(customView: userImageButton)
        navigationItem.rightBarButtonItem = barButton
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer()
        tap.rx.event.bind { [weak self] _ in
            self?.view.endEditing(true)
        }.disposed(by: disposeBag)
        view.addGestureRecognizer(tap)
    }

    @IBAction func sendMessage(_ sender: Any) {
        guard let text = messageTextView.text else { return }
        presenter.sendTextMessage(text: text)
        messageTextView.text = ""
        placeholderLabel.isHidden = false
        textBackViewHeightConstraint.constant = 35
        containerHeightConstraint.constant = 90
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func addAttachment(_ sender: Any) {
    }
    
    @objc private func handleKeyboard(_ notification: Notification) {
        if notification.name == UIResponder.keyboardWillHideNotification {
            view.frame.origin.y = 0
        } else {
            guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            view.frame.origin.y = -keyboardRect.height
        }
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
        userImageButton.kf.setImage(with: URL(string: peerImageURL), for: .normal, placeholder: UIImage.userPlaceholder, options: [.cacheOriginalImage], completionHandler: nil)
    }
    
    func setupMessages(messages: [MessageViewModel]) {
        let changeNumber = messages.count - self.messages.count
        self.messages = messages
        if changeNumber > 0 {
            var indexSet = [IndexPath]()
            for item in 0..<changeNumber {
                indexSet.append(IndexPath(item: item, section: 0))
            }
            self.collectionView.insertItems(at: indexSet)
        } else {
            self.collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.layoutSubviews()
        }
    }
    
    func addMessage(message: MessageViewModel) {
        messages.insert(message, at: 0)
        collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
    }
}

extension ChatViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextMessageCollectionViewCell.reuseIdentifier, for: indexPath) as! TextMessageCollectionViewCell
        cell.configureCell(with: message)
        return cell
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let messageText = messages[indexPath.item].text else { return CGSize(width: view.frame.width, height: 100) }
        let textRect = messageText.estimatedSize(width: 250, height: 2000, font: UIFont.systemFont(ofSize: 16))
        return CGSize(width: view.frame.width, height: textRect.height + 30)
    }
}

extension ChatViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = textView.text.isEmpty ? false : true
        if textView.contentSize.height > 45 {
            if textView.contentSize.height < 200 {
                let changeNumber = textView.contentSize.height - 35
                textBackViewHeightConstraint.constant = textView.contentSize.height + 10
                containerHeightConstraint.constant = 90 + changeNumber
            }
        } else {
            textBackViewHeightConstraint.constant = 35
            containerHeightConstraint.constant = 90
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
