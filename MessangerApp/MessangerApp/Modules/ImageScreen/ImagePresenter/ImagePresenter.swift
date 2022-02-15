//
//  ImagePresenter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/8/22.
//

import UIKit

class ImagePresenter {
    private var superviewImageRect: CGRect
    weak var view: ImageViewInput!
    var interactor: ImageInteractorInput!
    var router: ImageRouter!
    
    var image: UIImage?
    
    init(superviewImageRect: CGRect) {
        self.superviewImageRect = superviewImageRect
    }
}

extension ImagePresenter: ImagePresenterProtocol {
    
    func viewDidLoad() {
        guard let image = image else { return }
        view.presentImage(image, superviewImageRect: superviewImageRect)
    }
    
    func dismissView() {
        router.dismiss()
    }
}
