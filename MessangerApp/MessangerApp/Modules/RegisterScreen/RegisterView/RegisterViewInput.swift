//
//  RegisterViewInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import UIKit

protocol RegisterViewInput: AnyObject {
    func showError(error: Error)
    func showLoader()
    func hideLoader()
    func setAvatar(image: UIImage)
}
