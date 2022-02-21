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
    
    private let queue = DispatchQueue.global(qos: .background)
    private let dataCacher: DataCacherProtocol
    
    init(dataCacher: DataCacherProtocol) {
        self.dataCacher = dataCacher
    }
    
    private func fetchFile(with stringURL: String, completion: @escaping (URL?) -> Void) {
        queue.async {
            let fileURL = self.dataCacher.obtainFileURLFromRemoteURL(stringURL: stringURL)
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                completion(fileURL)
                return
            }

            let destination: DownloadRequest.Destination = { _, _ in
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
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
