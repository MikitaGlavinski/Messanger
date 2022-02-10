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
        displayCellData()
        if let localPath = messageModel.localPath, !localPath.isEmpty {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent("chatFiles/%\(model.id)")
            guard
                let data = try? Data(contentsOf: url),
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
    
    private func displayCellData() {
        guard let cellData = messageModel.cellData as? ImageCellData else { return }
        if configureWithDate {
            contentView.addSubview(dateLabel)
        }
        timeLabel.text = cellData.timeLabelText
        dateLabel.text = cellData.dateLabelText
        dateLabel.frame = cellData.dateLabelFrame ?? .zero
        imageView.frame = cellData.imageViewFrame
        timeLabel.frame = cellData.timeLabelFrame
        sendStateView.frame = cellData.sendStateViewFrame
        sendStateView.isHidden = cellData.isSendStateHidden
        sendStateView.layer.borderColor = cellData.sendStateViewBorderColor
        sendStateView.backgroundColor = cellData.sendStateViewBackgroundColor
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
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.removeFromSuperview()
        self.sendStateView.backgroundColor = .clear
        self.sendStateView.layer.borderColor = UIColor.systemRed.cgColor
        self.imageView.image = nil
        sendStateView.isHidden = false
        dateLabel.frame = .zero
        imageView.frame = .zero
        timeLabel.frame = .zero
        sendStateView.frame = .zero
    }
}
