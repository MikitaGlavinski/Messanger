//
//  UIImageView+Extension.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/7/22.
//

import UIKit

extension UIImageView {
    
    private var imageLoader: ImageLoaderProtocol? {
        let imageLoader: ImageLoader? = ServiceLocator.shared.getService()
        return imageLoader
    }
    
    func downloadImage(from stringURL: String) {
//        let activityIndicator = UIActivityIndicatorView(style: .medium)
//        activityIndicator.tintColor = .black
//        activityIndicator.frame = CGRect(x: frame.width / 2 - 15, y: frame.height / 2 - 15, width: 30, height: 30)
//        addSubview(activityIndicator)
//        activityIndicator.startAnimating()
        
        imageLoader?.fetchImage(with: stringURL) { image in
//            activityIndicator.stopAnimating()
//            activityIndicator.removeFromSuperview()
            guard let image = image else { return }
            self.image = image
        }
    }
}
