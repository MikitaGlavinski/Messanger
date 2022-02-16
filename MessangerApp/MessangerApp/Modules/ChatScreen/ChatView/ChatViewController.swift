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
        collectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
        presenter.addMessagesListener()
        setupGestures()
    }
    
    private func setupUI() {
        presenter.setupCollectionView(collectionView)
        messageTextView.delegate = self
        
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
        let actionSheet = UIAlertController(title: String.Titles.pickMedia, message: nil, preferredStyle: .actionSheet)
        let photoAction = UIAlertAction(title: String.Titles.photo, style: .default) { _ in
            let actionSheet = UIAlertController(title: String.Titles.pickMedia, message: nil, preferredStyle: .actionSheet)
            let libraryAction = UIAlertAction(title: String.Titles.photoLibrary, style: .default) { _ in
                self.presenter.pickPhoto(sourceType: .photoLibrary)
            }
            let cameraAction = UIAlertAction(title: String.Titles.camera, style: .default) { _ in
                self.presenter.pickPhoto(sourceType: .camera)
            }
            actionSheet.addAction(libraryAction)
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(UIAlertAction(title: String.Titles.cancel, style: .cancel, handler: nil))
            self.present(actionSheet, animated: true, completion: nil)
        }
        let videoAction = UIAlertAction(title: String.Titles.video, style: .default) { _ in
            let actionSheet = UIAlertController(title: String.Titles.pickMedia, message: nil, preferredStyle: .actionSheet)
            let libraryAction = UIAlertAction(title: String.Titles.photoLibrary, style: .default) { _ in
                self.presenter.pickVideo(sourceType: .photoLibrary)
            }
            let cameraAction = UIAlertAction(title: String.Titles.camera, style: .default) { _ in
                self.presenter.pickVideo(sourceType: .camera)
            }
            actionSheet.addAction(libraryAction)
            actionSheet.addAction(cameraAction)
            actionSheet.addAction(UIAlertAction(title: String.Titles.cancel, style: .cancel, handler: nil))
            self.present(actionSheet, animated: true, completion: nil)
        }
        actionSheet.addAction(photoAction)
        actionSheet.addAction(videoAction)
        actionSheet.addAction(UIAlertAction(title: String.Titles.cancel, style: .cancel, handler: nil))
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
