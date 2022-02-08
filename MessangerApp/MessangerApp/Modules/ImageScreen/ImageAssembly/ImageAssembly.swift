//
//  ImageAssembly.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/8/22.
//

import UIKit

class ImageAssembly {
    
    static func assemble(image: UIImage) -> UIViewController {
        let view = ImageViewController.instantiateWith(storyboard: .main) as! ImageViewController
        let presenter = ImagePresenter()
        let interactor = ImageInteractor()
        let router = ImageRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.image = image
        router.view = view
        
        return view
    }
}
