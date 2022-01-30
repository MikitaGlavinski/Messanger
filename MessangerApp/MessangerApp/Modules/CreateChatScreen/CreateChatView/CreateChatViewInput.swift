//
//  CreateChatViewInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 24.01.22.
//

import Foundation

protocol CreateChatViewInput: AnyObject {
    func showError(error: Error)
    func showLoader()
    func hideLoader()
}
