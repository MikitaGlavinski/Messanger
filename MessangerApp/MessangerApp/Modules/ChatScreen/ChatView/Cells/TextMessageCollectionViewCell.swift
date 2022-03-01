//
//  TextMessageCollectionViewCell.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/31/22.
//

import UIKit

class TextMessageCollectionViewCell: UICollectionViewCell {

    private var messageModel: MessageViewModel!
    var configureWithDate: Bool!
    weak var delegate: MessageActivitiesDelegate!
    
    lazy var messageView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.dataDetectorTypes = .link
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
        setupInteraction()
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
        messageView.addSubview(textView)
        contentView.addSubview(messageView)
        contentView.addSubview(sendStateView)
        contentView.addSubview(timeLabel)
    }
    
    private func setupInteraction() {
        let interaction = UIContextMenuInteraction(delegate: self)
        messageView.addInteraction(interaction)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.removeFromSuperview()
        self.sendStateView.backgroundColor = .clear
        self.sendStateView.layer.borderColor = UIColor.systemRed.cgColor
        sendStateView.isHidden = false
    }
}

extension TextMessageCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { action -> UIMenu? in
            let delete = UIAction(title: String.Titles.delete, image: UIImage(systemName: "trash.fill"), identifier: nil, discoverabilityTitle: nil, state: .off) { _ in
                self.delegate.deleteMessage(self.messageModel)
            }
            
            let forward = UIAction(title: String.Titles.forward, image: UIImage(systemName: "arrowshape.turn.up.forward.fill"), identifier: nil, discoverabilityTitle: nil, state: .off) { _ in
                self.delegate.forwardMessage(messageId: self.messageModel.id)
            }
            return UIMenu(title: String.Titles.options, image: nil, identifier: nil, options: .displayInline, children: [delete, forward])
        }
        return context
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: messageView.bounds, cornerRadius: 15)
        let targetView = UITargetedPreview(view: messageView, parameters: parameters)
        return targetView
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: messageView.bounds, cornerRadius: 15)
        let targetView = UITargetedPreview(view: messageView, parameters: parameters)
        return targetView
    }
}
