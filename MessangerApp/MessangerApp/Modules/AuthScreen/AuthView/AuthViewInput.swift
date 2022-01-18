//
//  AuthViewInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import Foundation

protocol AuthViewInput: AnyObject {
    func showError(error: Error)
    func showLoader()
    func hideLoader()
}
