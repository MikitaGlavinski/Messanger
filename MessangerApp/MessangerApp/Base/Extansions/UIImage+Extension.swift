//
//  UIImage+Extension.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 25.01.22.
//

import UIKit

extension UIImage {
    static var userPlaceholder: UIImage { UIImage(named: "userPlaceholder")! }
    
    func scaledSize(size: CGSize) -> CGSize {
        var scaledImageRect = CGRect.zero;

        let aspectWidth:CGFloat = size.width / self.size.width
        let aspectHeight:CGFloat = size.height / self.size.height
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)

        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        return scaledImageRect.size
    }
}
