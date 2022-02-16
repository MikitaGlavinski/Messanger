//
//  DataCacher.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/7/22.
//

import Foundation

protocol DataCacherProtocol {
    func cacheOriginalData(_ data: Data, id: String) -> String?
    func cacheDataPreview(_ data: Data, id: String) -> String?
    func obtainFileURL(fileId: String) -> URL
    func obtainFilePreviewURL(fileId: String) -> URL
    func deleteFileAt(url: URL) throws
    func obtainFileURLFromRemoteURL(stringURL: String) -> URL
}

class DataCacher: DataCacherProtocol {
    
    private func cacheData(_ data: Data, id: String) -> String? {
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
    
    func cacheOriginalData(_ data: Data, id: String) -> String? {
        cacheData(data, id: "%\(id)")
    }
    
    func cacheDataPreview(_ data: Data, id: String) -> String? {
        cacheData(data, id: "%preview\(id)")
    }
    
    func obtainFileURL(fileId: String) -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent("chatFiles/%\(fileId)")
        return url
    }
    
    func obtainFilePreviewURL(fileId: String) -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let previewURL = documents.appendingPathComponent("chatFiles/%preview\(fileId)")
        return previewURL
    }
    
    func deleteFileAt(url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
    
    func obtainFileURLFromRemoteURL(stringURL: String) -> URL {
        let firstComponent = stringURL.components(separatedBy: "%").last ?? ""
        var fileUUID = firstComponent.components(separatedBy: "?").first ?? ""
        fileUUID.removeFirst()
        fileUUID.removeFirst()
        let imagePath = "%\(fileUUID)"
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documentsURL.appendPathComponent("chatFiles")
        documentsURL.appendPathComponent(imagePath)
        
        return documentsURL
    }
}
