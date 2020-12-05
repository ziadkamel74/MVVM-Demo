//
//  SignUpVCPresenter.swift
//  TODOApp-MVP-Demo
//
//  Created by Ziad on 11/13/20.
//  Copyright © 2020 IDEAEG. All rights reserved.
//

import Foundation

class SignUpViewModel {
    
    // MARK:- Properties
    private weak var view: AuthenticationVCsProtocol?
    
    // MARK:- Init
    init(view: AuthenticationVCsProtocol) {
        self.view = view
    }
}

// MARK:- Private Methods
extension SignUpViewModel {
    private func isValidData(_ name: String?, _ email: String?, _ password: String?, _ age: String?) -> Bool {
        if let validationError = ValidationManager.shared.tryToCathchErrors(name: name, email: email, password: password, age: age) {
            view?.displayAlert(title: validationError.0, message: validationError.1)
            return false
        }
        return true
    }
    
    private func register(with user: UserData, completion: @escaping () -> Void) {
        view?.showLoader()
        APIManager.register(with: user) { [weak self] (response) in
            switch response {
            case .failure(let error):
                self?.view?.displayAlert(title: "Can't sign up", message: error.localizedDescription)
            case .success(let response):
                UserDefaultsManager.shared().token = response.token
                completion()
            }
            self?.view?.hideLoader()
        }
    }
    
}

// MARK:- ViewModel Protocol
extension SignUpViewModel: AuthenticationViewModelProtocol {
    func tryToRegister(name: String?, email: String?, password: String?, age: String?) {
        if isValidData(name, email, password, age) {
            let user = UserData(name: name, email: email, password: password, age: Int(age!))
            register(with: user) {
                self.view?.switchToMainState()
            }
        }
    }
}
