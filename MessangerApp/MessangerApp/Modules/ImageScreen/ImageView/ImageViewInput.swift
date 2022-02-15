//
//  ImageViewInput.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/8/22.
//

import UIKit

protocol ImageViewInput: AnyObject {
    func presentImage(_ image: UIImage, superviewImageRect: CGRect)
}
