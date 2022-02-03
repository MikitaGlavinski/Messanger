//
//  RegisterPresenter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 1/18/22.
//

import UIKit
import RxSwift

class RegisterPresenter: NSObject {
    weak var view: RegisterViewInput!
    var interactor: RegisterInteractorInput!
    var router: RegisterRouter!
    
    private let disposeBag = DisposeBag()
    private var imageURL: String?
    
    private func uploadImage(image: UIImage) {
        view.showLoader()
        guard let imageUploader = interactor.uploadImage(image: image) else { return }
        imageUploader
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] url in
                self?.view.hideLoader()
                self?.imageURL = url
                self?.view.setAvatar(image: image)
            }, onFailure: { [weak self] error in
                self?.view.hideLoader()
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
}

extension RegisterPresenter: RegisterPresenterProtocol {
    
    func register(with email: String, password: String) {
        view.showLoader()
        guard let createUser = interactor.createUser(email: email, password: password) else { return }
        createUser
            .flatMap({ [weak self] token -> Single<UserModel> in
                self?.interactor.saveToken(token: token)
                guard
                    let imageURL = self?.imageURL,
                    let userAdder = self?.interactor.addUser(user: UserModel(id: token, email: email, imageURL: imageURL))
                else {
                    return Single<UserModel>.error(NetworkError.requestError)
                }
                return userAdder
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.view.hideLoader()
                self?.router.routeToChatList()
            }, onFailure: { [weak self] error in
                self?.view.hideLoader()
                self?.view.showError(error: error)
            }).disposed(by: disposeBag)
    }
    
    func chooseImage() {
        router.showImagePicker(delegate: self)
    }
}

extension RegisterPresenter: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        picker.dismiss(animated: true, completion: nil)
        uploadImage(image: image)
    }
}
