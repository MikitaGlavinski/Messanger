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
    var membersIds: [String]
    
    init(id: String, members: [UserModel], membersIds: [String]) {
        self.id = id
        self.members = members
        self.membersIds = membersIds
    }
    
    init(chatAdapter: ChatStorageAdapter, userAdapters: [UserStorageAdapter]) {
        self.id = chatAdapter.id
        self.membersIds = chatAdapter.membersIds.components(separatedBy: ",")
        self.members = userAdapters.compactMap({UserModel(userAdapter: $0)})
    }
}
