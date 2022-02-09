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

class ChatCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

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
        navigationController?.navigationBar.isHidden = false
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
        let layout = ChatCollectionViewLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: 1, height: 1 )
        collectionView.collectionViewLayout = layout
        collectionView.register(TextMessageCollectionViewCell.self, forCellWithReuseIdentifier: TextMessageCollectionViewCell.reuseIdentifier)
        collectionView.register(ImageMessageCollectionViewCell.self, forCellWithReuseIdentifier: ImageMessageCollectionViewCell.reuseIdentifier)
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
        guard let text = messageTextView.text, !text.isEmpty else { return }
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
        let actionSheet = UIAlertController(title: "Pick Media", message: nil, preferredStyle: .actionSheet)
        let photoAction = UIAlertAction(title: "Photo", style: .default) { _ in
            let actionSheet = UIAlertController(title: "Pick Media", message: nil, preferredStyle: .actionSheet)
            let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
                self.presenter.pickPhoto()
            }
            actionSheet.addAction(libraryAction)
            self.present(actionSheet, animated: true, completion: nil)
        }
        actionSheet.addAction(photoAction)
        present(actionSheet, animated: true, completion: nil)
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
        }
    }
    
    func addMessage(message: MessageViewModel) {
        messages.insert(message, at: 0)
        collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
    }
    
    func updateMessage(message: MessageViewModel) {
        guard let index = messages.firstIndex(where: {$0.id == message.id}) else { return }
        messages[index] = message
        self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
}

extension ChatViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        let showDate = message.cellData?.showDate ?? false
        let cell = message.getCollectionCell(from: collectionView, showDate: showDate, indexPath: indexPath, delegate: self)
        return cell
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: messages[indexPath.item].cellData?.cellHeight ?? 350)
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

extension ChatViewController: MessageActivitiesDelegate {
    func openImage(with image: UIImage, of imageView: UIImageView) {
        let parentRect = view.convert(imageView.frame, from: imageView.superview)
        let animatedImage = UIImageView()
        animatedImage.contentMode = .scaleAspectFit
        animatedImage.image = image
        animatedImage.frame = parentRect
        animatedImage.layer.cornerRadius = 15
        animatedImage.clipsToBounds = true
        view.addSubview(animatedImage)
        imageView.image = nil
        UIView.animate(withDuration: 0.2) {
            animatedImage.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        } completion: { _ in
            self.presenter.openImage(with: image)
            imageView.image = image
            animatedImage.removeFromSuperview()
        }
    }
}
