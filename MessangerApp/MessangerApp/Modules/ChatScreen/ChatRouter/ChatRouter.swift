//
//  ChatRouter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import UIKit

class ChatRouter {
    weak var view: UIViewController!
    
    func pickLibraryPhoto(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)) {
        let picker = UIImagePickerController()
        picker.delegate = delegate
        picker.allowsEditing = true
        picker.mediaTypes = ["public.image"]
        picker.sourceType = .photoLibrary
        view.present(picker, animated: true, completion: nil)
    }
    
    func openImageMessage(with image: UIImage) {
        let imageView = ImageAssembly.assemble(image: image)
        UIView.transition(with: view.view.superview!, duration: 0.2, options: [.transitionCrossDissolve]) {
            imageView.willMove(toParent: self.view)
            self.view.addChild(imageView)
            self.view.view.addSubview(imageView.view)
        }
    }
}
