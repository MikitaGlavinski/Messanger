//
//  ForwardChatListViewController.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/23/22.
//

import UIKit

class ForwardChatListViewController: BaseViewController {
    
    var presenter: ForwardChatListPresenterProtocol!
    @IBOutlet weak var tableView: UITableView!
    
    private var chatModels: [ChatViewModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func cancelForward(_ sender: Any) {
        presenter.hideForwardChatList()
    }
}

extension ForwardChatListViewController: ForwardChatListViewInput {
    
    func setupChats(chatModels: [ChatViewModel]) {
        self.chatModels = chatModels
    }
}

extension ForwardChatListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ForwardChatListTableViewCell.reuseIdentifier) as! ForwardChatListTableViewCell
        cell.configure(with: chatModels[indexPath.row])
        return cell
    }
}

extension ForwardChatListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chat = chatModels[indexPath.row]
        presenter.forwardMessage(chatId: chat.chatId)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
