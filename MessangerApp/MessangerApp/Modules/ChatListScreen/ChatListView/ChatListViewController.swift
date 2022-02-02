//
//  ChatListViewController.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import UIKit

class ChatListViewController: BaseViewController {
    
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
    
    private var chatModels = [ChatViewModel]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        presenter.addMessagesListener()
        setupUI()
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        let titleStackView = UIStackView(arrangedSubviews: [chatTitleLabel, updatingLabel])
        titleStackView.axis = .vertical
        titleStackView.distribution = .equalSpacing
        titleStackView.spacing = 7
        navigationItem.titleView = titleStackView
    }
    
    @IBAction func addChat(_ sender: Any) {
        presenter.addChat()
    }
}

extension ChatListViewController: ChatListViewInput {
    func updateChatList(chatModels: [ChatViewModel]) {
        self.chatModels = chatModels
    }
    
    func showUpdating() {
        self.updatingLabel.isHidden = false
    }
    
    func hideUpdating() {
        self.updatingLabel.isHidden = true
    }
}

extension ChatListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatListTableViewCell.reuseIdentifier) as! ChatListTableViewCell
        cell.configureCell(with: chatModels[indexPath.row])
        return cell
    }
}

extension ChatListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.openChat(with: chatModels[indexPath.row].chatId)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
