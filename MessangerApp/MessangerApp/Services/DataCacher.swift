//
//  DataCacher.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/7/22.
//

import Foundation

protocol DataCacherProtocol {
    func cacheData(_ data: Data, id: String) -> String?
}

class DataCacher: DataCacherProtocol {
    
    func cacheData(_ data: Data, id: String) -> String? {
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documentsURL.appendPathComponent("chatFiles")
        
        do {
            try FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
            documentsURL.appendPathComponent(id)
            try data.write(to: documentsURL)
            return documentsURL.path
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}
