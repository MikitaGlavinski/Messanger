//
//  ChatListViewController.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import UIKit

class ChatListViewController: UIViewController {
    
    var presenter: ChatListPresenterProtocol!

    @IBOutlet weak var updatingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension ChatListViewController: ChatListViewInput {
    
}
