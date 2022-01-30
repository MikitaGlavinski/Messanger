//
//  BaseViewController.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import UIKit

class BaseViewController: UIViewController {
    
    private lazy var blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blur)
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.tintColor = .systemGreen
        view.hidesWhenStopped = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showError(error: Error) {
        var alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        if let netError = error as? NetworkError {
            alert = UIAlertController(title: "Error", message: netError.rawValue, preferredStyle: .alert)
        }
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showLoader() {
        blurView.frame = view.bounds
        activityIndicator.frame = CGRect(x: view.frame.midX - 20, y: view.frame.midY - 20, width: 40, height: 40)
        activityIndicator.startAnimating()
        view.addSubview(blurView)
        view.addSubview(activityIndicator)
    }
    
    func hideLoader() {
        activityIndicator.removeFromSuperview()
        blurView.removeFromSuperview()
    }
}
