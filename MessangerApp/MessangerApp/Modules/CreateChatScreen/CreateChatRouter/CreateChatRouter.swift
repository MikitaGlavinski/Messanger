//
//  CreateChatRouter.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 24.01.22.
//

import UIKit

class CreateChatRouter {
    weak var view: UIViewController!
    
    func dismissView() {
        view.navigationController?.popViewController(animated: true)
    }
}
