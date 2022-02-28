//
//  ChatRouter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 30.01.22.
//

import UIKit
import AVKit

class ChatRouter {
    weak var view: UIViewController!
    
    func getPhoto(sourceType: UIImagePickerController.SourceType, delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)) {
        let picker = UIImagePickerController()
        picker.delegate = delegate
        picker.mediaTypes = ["public.image"]
        picker.sourceType = sourceType
        view.present(picker, animated: true, completion: nil)
    }
    
    func getVideo(sourceType: UIImagePickerController.SourceType, delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)) {
        let picker = UIImagePickerController()
        picker.delegate = delegate
        picker.sourceType = sourceType
        picker.mediaTypes = ["public.movie"]
        view.present(picker, animated: true, completion: nil)
    }
    
    func openImageMessage(with image: UIImage, superViewImageRect: CGRect, completion: @escaping () -> Void) {
        let imageView = ImageAssembly.assemble(image: image, superViewImageRect: superViewImageRect, completion: completion)
        UIView.transition(with: view.view, duration: 0.2, options: [.transitionCrossDissolve]) {
            imageView.willMove(toParent: self.view)
            self.view.addChild(imageView)
            self.view.view.addSubview(imageView.view)
        }
    }
    
    func playVideo(with url: URL) {
        let playerController = AVPlayerViewController()
        let player = AVPlayer(url: url)
        playerController.player = player
        view.present(playerController, animated: true) {
            playerController.player?.play()
        }
    }
    
    func routeToForwardChatList(messsageId: String) {
        let forwardChatList = ForwardChatListAssembly.assemble(messageId: messsageId)
        view.present(forwardChatList, animated: true, completion: nil)
    }
}
