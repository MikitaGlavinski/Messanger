//
//  TextMessageCollectionViewCell.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/31/22.
//

import UIKit

class TextMessageCollectionViewCell: UICollectionViewCell {

    private var messageModel: MessageViewModel!
    
    private lazy var messageView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        return textView
    }()
    
    private lazy var sendStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.MessengerColors.ownerMessageColor.cgColor
        view.layer.cornerRadius = 3
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        contentView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    func configureCell(with model: MessageViewModel) {
        self.messageModel = model
        handleMessage()
    }
    
    private func setupUI() {
        contentView.addSubview(messageView)
        contentView.addSubview(textView)
        contentView.addSubview(sendStateView)
    }
    
    private func handleMessage() {
        guard let text = self.messageModel.text else { return }
        let paddingNumber: CGFloat = UIDevice.current.orientation.isLandscape ? self.safeAreaInsets.right : 16
        let textRect = text.estimatedSize(width: 250, height: 2000, font: UIFont.systemFont(ofSize: 16))
        if !self.messageModel.isOwner {
            self.messageView.frame = CGRect(x: paddingNumber, y: 10, width: textRect.width + 16 + 11, height: textRect.height + 20)
            self.textView.frame = CGRect(x: paddingNumber + 8, y: 11, width: textRect.width + 16, height: textRect.height + 20)
            self.sendStateView.isHidden = true
            
            self.messageView.backgroundColor = UIColor.MessengerColors.peerMessageColor
            self.textView.textColor = .white
        } else {
            self.messageView.frame = CGRect(x: self.contentView.frame.width - textRect.width - paddingNumber - 8 - 16, y: 10, width: textRect.width + 16 + 11, height: textRect.height + 20)
            self.textView.frame = CGRect(x: self.contentView.frame.width - textRect.width - paddingNumber - 16, y: 11, width: textRect.width + 16, height: textRect.height + 20)
            self.sendStateView.frame = CGRect(x: self.messageView.frame.minX - 11, y: self.messageView.frame.maxY - 6, width: 6, height: 6)
            
            self.messageView.backgroundColor = UIColor.MessengerColors.ownerMessageColor
            self.textView.textColor = .white
        }
        if text.containsOnlyEmoji {
            self.messageView.backgroundColor = .clear
        }
        self.sendStateView.backgroundColor = self.messageModel.isSent ? UIColor.MessengerColors.ownerMessageColor : .clear
        self.textView.text = text
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        handleMessage()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sendStateView.isHidden = false
    }
}
