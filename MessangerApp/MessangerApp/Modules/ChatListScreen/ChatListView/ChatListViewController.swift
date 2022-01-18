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
    @IBOutlet weak var updatingLabel: UILabel!
    
    private var chatModels = [ChatModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addChat(_ sender: UIButton) {
    }
}

extension ChatListViewController: ChatListViewInput {
    
}
