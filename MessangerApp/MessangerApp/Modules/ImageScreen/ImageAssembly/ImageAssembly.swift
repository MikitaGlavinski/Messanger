//
//  ImageAssembly.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/8/22.
//

import UIKit

class ImageAssembly {
    
    static func assemble(image: UIImage, superViewImageRect: CGRect, completion: @escaping() -> Void) -> UIViewController {
        let view = ImageViewController.instantiateWith(storyboard: .main) as! ImageViewController
        let presenter = ImagePresenter(superviewImageRect: superViewImageRect)
        let interactor = ImageInteractor()
        let router = ImageRouter(completion: completion)
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.image = image
        router.view = view
        
        return view
    }
}
