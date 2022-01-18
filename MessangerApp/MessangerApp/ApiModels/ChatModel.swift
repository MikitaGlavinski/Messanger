//
//  ChatModel.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import Foundation

struct ChatModel: Codable {
    var id: String
    var members: [UserModel]
}
