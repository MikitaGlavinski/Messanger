//
//  NetworkError.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import Foundation

enum NetworkError: String, Error {
    case noData = "No data"
    case noConnection = "No connection"
    case requestError = "Request Error"
    case decodeError = "Can't decode"
    case invalidEmail = "Invalid Email"
    case chatAlreadyCreated = "Chat is already created"
    case unrecognized = "UNRECOGNIZED"
}
