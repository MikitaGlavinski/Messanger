//
//  String+Extension.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/31/22.
//

import UIKit

extension String {
    func estimatedSize(width: CGFloat, height: CGFloat, font: UIFont) -> CGRect {
        let size = CGSize(width: width, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: self).boundingRect(with: size, options: options, attributes: [.font: font], context: nil)
        return estimatedFrame
    }
}
