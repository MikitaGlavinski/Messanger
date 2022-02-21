//
//  ReachabilityService.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/21/22.
//

import Foundation
import Reachability

protocol ReachabilityServiceProtocol {
    func isReachable() -> Bool
}

class ReachabilityService: ReachabilityServiceProtocol {
    
    private let reachability = try! Reachability()
    private let chatSignalService: ChatSignalServiceProtocol
    
    init(chatSignalService: ChatSignalService) {
        self.chatSignalService = chatSignalService
        setupReachability()
    }
    
    private func setupReachability() {
        reachability.whenReachable = { reachability in
            let chatSignalService: ChatSignalService? = ServiceLocator.shared.getService()
            chatSignalService?.signalStartSending()
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to notifier reachability")
        }
    }
    
    func isReachable() -> Bool {
        return !(reachability.connection == .unavailable)
    }
}
