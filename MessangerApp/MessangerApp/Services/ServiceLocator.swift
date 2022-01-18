//
//  ServiceLocator.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/17/22.
//

import Foundation

final class ServiceLocator {
    
    static let shared = ServiceLocator()
    private init() {}
    
    var services = [String: Any]()
    
    private func typeName(some: Any) -> String {
        return some is Any.Type ? "\(some)" : "\(type(of: some))"
    }
    
    func addService<T>(service: T) {
        let key = typeName(some: service)
        services[key] = service
    }
    
    func getService<T>() -> T? {
        let key = typeName(some: T.self)
        return services[key] as? T
    }
}
