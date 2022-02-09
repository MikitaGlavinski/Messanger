//
//  TextMessageCollectionViewCell.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/31/22.
//

import UIKit

protocol MessageActivitiesDelegate: AnyObject {
    func openImage(with image: UIImage, of imageView: UIImageView)
}

class TextMessageCollectionViewCell: UICollectionViewCell {

    private var messageModel: MessageViewModel!
    var configureWithDate: Bool!
    
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
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .systemBlue
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .darkGray
        label.backgroundColor = .clear
        return label
    }()
    
    private lazy var sendStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemRed.cgColor
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
        displayCellData()
    }
    
    private func displayCellData() {
        guard let cellData = messageModel.cellData as? TextCellData else { return }
        if configureWithDate {
            contentView.addSubview(dateLabel)
        }
        timeLabel.text = cellData.timeLabelText
        dateLabel.text = cellData.dateLabelText
        dateLabel.frame = cellData.dateLabelFrame ?? .zero
        messageView.frame = cellData.textMessageBackViewFrame
        textView.frame = cellData.textViewFrame
        timeLabel.frame = cellData.timeLabelFrame
        sendStateView.frame = cellData.sendStateViewFrame
        sendStateView.isHidden = cellData.isSendStateHidden
        sendStateView.layer.borderColor = cellData.sendStateViewBorderColor
        sendStateView.backgroundColor = cellData.sendStateViewBackgroundColor
        messageView.backgroundColor = cellData.messageBackgroundColor
        textView.textColor = cellData.textColor
        textView.text = messageModel.text
    }
    
    private func setupUI() {
        contentView.addSubview(messageView)
        contentView.addSubview(textView)
        contentView.addSubview(sendStateView)
        contentView.addSubview(timeLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.removeFromSuperview()
        self.sendStateView.backgroundColor = .clear
        self.sendStateView.layer.borderColor = UIColor.systemRed.cgColor
        sendStateView.isHidden = false
    }
}
