//
//  ChatViewController.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import UIKit

class ChatViewController: BaseViewController {
    
    var presenter: ChatPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension ChatViewController: ChatViewInput {
    
}
