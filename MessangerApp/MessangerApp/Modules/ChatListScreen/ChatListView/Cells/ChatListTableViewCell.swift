//
//  ChatListTableViewCell.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import UIKit
import Kingfisher

class ChatListTableViewCell: UITableViewCell {
    

    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var chatTitleLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    private var chatModel: ChatViewModel! {
        didSet {
            var imageURL: URL?
            if let stringURL = chatModel.chatImageURL {
                imageURL = URL(string: stringURL)
            }
            chatImageView.kf.setImage(with: imageURL, placeholder: UIImage.userPlaceholder, options: [.cacheMemoryOnly], completionHandler: nil)
            chatTitleLabel.text = chatModel.title
            lastMessageLabel.text = chatModel.lastMessageText
            dateLabel.text = chatModel.lastMessageDate
            unreadCountLabel.text = "\(chatModel.unreadMessageCount)"
        }
    }
    
    func configureCell(with model: ChatViewModel) {
        setupUI()
        self.chatModel = model
    }
    
    private func setupUI() {
        unreadCountLabel.layer.cornerRadius = 12.5
    }
}
