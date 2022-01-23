//
//  ChatListViewController.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import UIKit

class ChatListViewController: UIViewController {
    
    var presenter: ChatListPresenterProtocol!

    @IBOutlet weak var tableView: UITableView!
    
    private lazy var chatTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Chats"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var updatingLabel: UILabel = {
       let label = UILabel()
        label.text = "updating..."
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.isHidden = true
        return label
    }()
    
    private var chatModels = [ChatViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        let titleStackView = UIStackView(arrangedSubviews: [chatTitleLabel, updatingLabel])
        titleStackView.axis = .vertical
        titleStackView.distribution = .equalSpacing
        titleStackView.spacing = 7
        navigationItem.titleView = titleStackView
    }

    @IBAction func addChat(_ sender: UIButton) {
    }
}

extension ChatListViewController: ChatListViewInput {
    
}
