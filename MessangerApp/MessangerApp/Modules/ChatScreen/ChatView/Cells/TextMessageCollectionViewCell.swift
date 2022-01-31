//
//  TextMessageCollectionViewCell.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/31/22.
//

import UIKit

class TextMessageCollectionViewCell: UICollectionViewCell {
    
    private var messageModel: MessageViewModel! {
        didSet {
            guard let text = messageModel.text else { return }
            let textRect = text.estimatedSize(width: 300, height: 2000, font: UIFont.systemFont(ofSize: 16))
            if messageModel.isOwner {
                messageView.frame = CGRect(x: 16, y: 0, width: textRect.width + 16 + 8, height: textRect.height + 20)
                textView.frame = CGRect(x: 16 + 8, y: 0, width: textRect.width + 16, height: textRect.height + 20)
                messageView.backgroundColor = UIColor.MessengerColors.ownerMessageColor
                textView.textColor = .black
            } else {
                messageView.frame = CGRect(x: contentView.frame.width - textRect.width - 16 - 8 - 16, y: 0, width: textRect.width + 16 + 8, height: textRect.height + 20)
                textView.frame = CGRect(x: contentView.frame.width - textRect.width - 16 - 16, y: 0, width: textRect.width + 16, height: textRect.height + 20)
                messageView.backgroundColor = UIColor.MessengerColors.peerMessageColor
                textView.textColor = .white
            }
            textView.text = text
        }
    }
    
    private lazy var messageView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        return view
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    func configureCell(with model: MessageViewModel) {
        self.messageModel = model
    }
    
    private func setupUI() {
        contentView.addSubview(messageView)
        contentView.addSubview(textView)
    }

}
