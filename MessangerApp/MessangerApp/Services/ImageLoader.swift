//
//  ImageLoader.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/7/22.
//

import UIKit
import Alamofire

protocol ImageLoaderProtocol {
    func fetchImage(with stringURL: String, completion: @escaping (UIImage?) -> Void)
}

class ImageLoader: ImageLoaderProtocol {
    
    private let queue = DispatchQueue(label: "image.loader", qos: .userInteractive)
    
    func fetchImage(with stringURL: String, completion: @escaping (UIImage?) -> Void) {
        queue.async {
            let firstComponent = stringURL.components(separatedBy: "%").last ?? ""
            var imageUUID = firstComponent.components(separatedBy: "?").first ?? ""
            imageUUID.removeFirst()
            imageUUID.removeFirst()
            let imagePath = "%\(imageUUID)"
            
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("chatFiles")
            documentsURL.appendPathComponent(imagePath)
            
            if FileManager.default.fileExists(atPath: documentsURL.path) {
                let url = URL(fileURLWithPath: documentsURL.path)
                guard
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
                return
            }
            
            let destination: DownloadRequest.Destination = { _, _ in
                return (documentsURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            AF.download(stringURL, to: destination).response { response in
                if let imagePath = response.fileURL?.path, response.error == nil {
                    let image = UIImage(contentsOfFile: imagePath)
                    completion(image)
                    return
                }
                completion(nil)
            }
        }
    }
}
