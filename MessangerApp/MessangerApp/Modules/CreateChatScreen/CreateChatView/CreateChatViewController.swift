//
//  CreateChatViewController.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 24.01.22.
//

import UIKit

class CreateChatViewController: BaseViewController {
    
    var presenter: CreateChatPresenterProtocol!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createChat(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        presenter.createChat(userEmail: email)
    }
}

extension CreateChatViewController: CreateChatViewInput {
    
}
