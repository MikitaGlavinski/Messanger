//
//  UIViewController+Extension.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 24.01.22.
//

import UIKit

extension UIViewController {
    
    static func instantiateWith(storyboard: UIStoryboard) -> UIViewController {
        let identifier = String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}
