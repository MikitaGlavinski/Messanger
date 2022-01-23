//
//  DateFormatterService.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 19.01.22.
//

import Foundation

class DateFormatterService {
    
    static var shared = DateFormatterService()
    private init() {}
    
    let formatter = DateFormatter()
    
    func formatDate(doubleDate: Double, format: String) -> String {
        formatter.dateFormat = format
        let date = Date(timeIntervalSince1970: doubleDate)
        return formatter.string(from: date)
    }
}
