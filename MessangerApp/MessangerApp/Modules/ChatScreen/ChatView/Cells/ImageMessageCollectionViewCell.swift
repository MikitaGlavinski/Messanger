//
//  ImageMessageCollectionViewCell.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/7/22.
//

import UIKit
import RxCocoa
import RxSwift

class ImageMessageCollectionViewCell: UICollectionViewCell {
    
    private var messageModel: MessageViewModel!
    var configureWithDate: Bool!
    weak var delegate: MessageActivitiesDelegate!
    private let disposeBag = DisposeBag()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.isUserInteractionEnabled = true
        return imageView
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
        setupGestures()
        contentView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    func configureCell(with model: MessageViewModel) {
        self.messageModel = model
        handleMessage()
        if let localPath = messageModel.localPath, localPath.count > 0 {
            guard
                let data = try? Data(contentsOf: URL(fileURLWithPath: localPath)),
                let image = UIImage(data: data)
            else {
                return
            }
            imageView.image = image
            return
        }
        guard let fileURL = messageModel.fileURL else { return }
        imageView.downloadImage(from: fileURL)
    }
    
    private func handleMessage() {
        timeLabel.text = messageModel.date
        
        if configureWithDate {
            contentView.addSubview(dateLabel)
            dateLabel.text = DateFormatterService.shared.formatDate(doubleDate: messageModel.doubleDate, format: "dd.MM.yy")
        }
        
        let paddingNumber: CGFloat = UIDevice.current.orientation.isLandscape ? self.safeAreaInsets.right : 16
        if !self.messageModel.isOwner {
            if configureWithDate {
                self.dateLabel.frame = CGRect(x: (contentView.frame.width / 2) - 40, y: 10, width: 80, height: 15)
                self.imageView.frame = CGRect(x: paddingNumber + 3, y: 33, width: 250, height: messageModel.previewHeight ?? 0)
            } else {
                self.imageView.frame = CGRect(x: paddingNumber + 3, y: 13, width: 250, height: messageModel.previewHeight ?? 0)
            }
            self.timeLabel.frame = CGRect(x: self.imageView.frame.maxX + 11, y: self.imageView.frame.maxY - 10, width: 30, height: 10)
            self.sendStateView.isHidden = true
        } else {
            if configureWithDate {
                self.dateLabel.frame = CGRect(x: (contentView.frame.width / 2) - 40, y: 10, width: 80, height: 15)
                self.imageView.frame = CGRect(x: self.contentView.frame.width - 250 - paddingNumber + 3, y: 33, width: 250, height: messageModel.previewHeight ?? 0)
            } else {
                self.imageView.frame = CGRect(x: self.contentView.frame.width - 250 - paddingNumber + 3, y: 13, width: 250, height: messageModel.previewHeight ?? 0)
            }
            self.timeLabel.frame = CGRect(x: self.imageView.frame.minX - 11 - 25, y: self.imageView.frame.maxY - 10, width: 30, height: 10)
            self.sendStateView.frame = CGRect(x: self.timeLabel.frame.minX - 11, y: self.imageView.frame.maxY - 6, width: 6, height: 6)
        }
        self.sendStateView.layer.borderColor = self.messageModel.isSent ? UIColor.MessengerColors.ownerMessageColor.cgColor : UIColor.systemRed.cgColor
        self.sendStateView.backgroundColor = self.messageModel.isRead ? UIColor.MessengerColors.ownerMessageColor : .clear
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(sendStateView)
        contentView.addSubview(timeLabel)
    }
    
    private func setupGestures() {
        let imageTap = UITapGestureRecognizer()
        imageTap.rx.event.bind { [weak self] _ in
            guard
                let imageView = self?.imageView,
                let image = self?.imageView.image else { return }
            self?.delegate.openImage(with: image, of: imageView)
        }.disposed(by: disposeBag)
        imageView.addGestureRecognizer(imageTap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        handleMessage()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.removeFromSuperview()
        self.sendStateView.backgroundColor = .clear
        self.sendStateView.layer.borderColor = UIColor.systemRed.cgColor
        self.imageView.image = nil
        sendStateView.isHidden = false
    }
}
