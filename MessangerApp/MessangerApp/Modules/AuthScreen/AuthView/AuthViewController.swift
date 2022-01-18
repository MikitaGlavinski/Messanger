//
//  AuthViewController.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import UIKit
import RxSwift
import RxCocoa

class AuthViewController: BaseViewController {
    
    var presenter: AuthPresenterProtocol!
    private let disposeBag = DisposeBag()

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
    }
    
    private func setupGestures() {
        let hideKeyboardTap = UITapGestureRecognizer()
        hideKeyboardTap.rx.event.bind { [weak self] _ in
            self?.view.endEditing(true)
        }.disposed(by: disposeBag)
        view.addGestureRecognizer(hideKeyboardTap)
    }
    
    private func checkCredentials() {
        if emailTextField.text?.isEmpty == true || passwordTextField.text?.isEmpty == true {
            emailTextField.frame.origin.x += 20
            passwordTextField.frame.origin.x += 20
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut) {
                self.emailTextField.frame.origin.x -= 20
                self.passwordTextField.frame.origin.x -= 20
            }
        } else {
            guard
                let email = self.emailTextField.text,
                let password = self.passwordTextField.text else {
                    return
                }
            self.presenter.signInWith(email: email, password: password)
        }
    }

    @IBAction func signIn(_ sender: UIButton) {
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
    
    @IBAction func signUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            } completion: { _ in
                self.presenter.showRegisterScreen()
            }
        }
    }
}

extension AuthViewController: AuthViewInput {
    
}
