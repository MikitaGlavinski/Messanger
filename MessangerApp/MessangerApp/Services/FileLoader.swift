//
//  ImageLoader.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/7/22.
//

import UIKit
import Alamofire

protocol FileLoaderProtocol {
    func fetchImage(with stringURL: String, completion: @escaping (UIImage?) -> Void)
    func fetchVideo(with stringURL: String, completion: @escaping (URL?) -> Void)
}

class FileLoader: FileLoaderProtocol {
    
    private let queue = DispatchQueue.global(qos: .userInteractive)
    
    private func fetchFile(with stringURL: String, completion: @escaping (URL?) -> Void) {
        queue.async {
            let firstComponent = stringURL.components(separatedBy: "%").last ?? ""
            var fileUUID = firstComponent.components(separatedBy: "?").first ?? ""
            fileUUID.removeFirst()
            fileUUID.removeFirst()
            let imagePath = "%\(fileUUID)"
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("chatFiles")
            documentsURL.appendPathComponent(imagePath)
            
            if FileManager.default.fileExists(atPath: documentsURL.path) {
                completion(documentsURL)
                return
            }

            let destination: DownloadRequest.Destination = { _, _ in
                return (documentsURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            AF.download(stringURL, to: destination).response { response in
                if let fileURL = response.fileURL, response.error == nil {
                    completion(fileURL)
                    return
                }
                completion(nil)
            }
        }
    }
    
    func fetchImage(with stringURL: String, completion: @escaping (UIImage?) -> Void) {
        fetchFile(with: stringURL) { url in
            guard
                let url = url,
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func fetchVideo(with stringURL: String, completion: @escaping (URL?) -> Void) {
        fetchFile(with: stringURL) { url in
            guard let url = url else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(url)
            }
        }
    }
}
