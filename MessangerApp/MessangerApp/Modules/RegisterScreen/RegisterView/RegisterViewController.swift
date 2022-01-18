//
//  RegisterViewController.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import UIKit

class RegisterViewController: BaseViewController {
    
    var presenter: RegisterPresenterProtocol!

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func checkCredentials() {
        if emailTextField.text?.isEmpty == true || passwordTextField.text?.isEmpty == true || passwordTextField.text != confirmPasswordTextField.text {
            emailTextField.frame.origin.x += 20
            passwordTextField.frame.origin.x += 20
            confirmPasswordTextField.frame.origin.x += 20
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.emailTextField.frame.origin.x -= 20
                self.passwordTextField.frame.origin.x -= 20
                self.confirmPasswordTextField.frame.origin.x -= 20
            }
        } else {
            guard
                let email = emailTextField.text,
                let password = passwordTextField.text else {
                    return
                }
            presenter.register(with: email, password: password)
        }
    }
    

    @IBAction func signUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            } completion: { _ in
                self.checkCredentials()
            }
        }
    }
}

extension RegisterViewController: RegisterViewInput {
    
}
