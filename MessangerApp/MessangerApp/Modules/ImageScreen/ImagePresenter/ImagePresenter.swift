//
//  ImagePresenter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/8/22.
//

import UIKit

class ImagePresenter {
    weak var view: ImageViewInput!
    var interactor: ImageInteractorInput!
    var router: ImageRouter!
    
    var image: UIImage?
}

extension ImagePresenter: ImagePresenterProtocol {
    
    func viewDidLoad() {
        guard let image = image else { return }
        view.presentImage(image)
    }
    
    func dismissView() {
        router.dismiss()
    }
}
