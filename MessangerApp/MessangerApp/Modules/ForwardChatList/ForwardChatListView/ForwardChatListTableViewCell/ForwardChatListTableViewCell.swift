//
//  ForwardChatListTableViewCell.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/24/22.
//

import UIKit
import Kingfisher

class ForwardChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var chatTitlelabel: UILabel!
    
    func configure(with model: ChatViewModel) {
        chatTitlelabel.text = model.title
        
        guard let imageURL = URL(string: model.chatImageURL ?? "") else { return }
        chatImageView.kf.setImage(with: imageURL, placeholder: UIImage.userPlaceholder, options: [.cacheOriginalImage], completionHandler: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        chatTitlelabel.text = nil
        chatImageView.image = nil
    }
}
