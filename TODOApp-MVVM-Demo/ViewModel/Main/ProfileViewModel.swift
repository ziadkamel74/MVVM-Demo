//
//  ProfilePresenter.swift
//  TODOApp-MVP-Demo
//
//  Created by Ziad on 11/21/20.
//  Copyright © 2020 IDEAEG. All rights reserved.
//

import UIKit // special case require UIKit

protocol ProfileViewModelProtocol {
    func getUserData()
    func didSelectRow(at indexPath: IndexPath)
    func logOut()
    func deleteAccount()
    func uploadImage(with data: Data?)
    func deleteUserImage()
    func updateUserInfo(name: String?, age: String?, email: String?)
}

class ProfileViewModel {
    // MARK:- Properties
    private weak var view: ProfileVCProtocol?
    
    // MARK:- Init
    init(view: ProfileVCProtocol) {
        self.view = view
    }
}

// MARK:- Private Methods
extension ProfileViewModel {
    private func nameToUpdate(_ name: String?) -> String? {
        if let name = name, !name.isEmpty, ValidationManager.shared.isValidName(name) {
            return name
        } else if let name = name, !name.isEmpty, !ValidationManager.shared.isValidName(name) {
            view?.displayAlert(title: ValidationError.name.error.title, message: ValidationError.name.error.message)
        }
        return nil
    }
    
    private func emailToUpdate(_ email: String?) -> String? {
        if let email = email, !email.isEmpty, ValidationManager.shared.isValidEmail(email) {
            return email
        } else if let email = email, !email.isEmpty, !ValidationManager.shared.isValidEmail(email) {
            view?.displayAlert(title: ValidationError.email.error.title, message: ValidationError.email.error.message)
        }
        return nil
    }
    
    private func ageToUpdate(_ age: String?) -> Int? {
        if let age = age, !age.isEmpty, ValidationManager.shared.isValidAge(age) {
            return Int(age)
        } else if let age = age, !age.isEmpty, !ValidationManager.shared.isValidAge(age) {
            view?.displayAlert(title: ValidationError.age.error.title, message: ValidationError.age.error.message)
        }
        return nil
    }
    
    private func showUserInfo(with userData: UserData) {
        guard let userName = userData.name,
            let userAge = userData.age, let userEmail = userData.email else { return }
        configureImageLabel(with: userName)
        view?.showUserInfo(userName, userEmail, String(userAge))
    }
    
    private func getUserImage(with id: String) {
        self.view?.showLoader()
        APIManager.getUserImage(with: id) { [weak self] (response) in
            switch response {
            case .failure:
                self?.view?.showImageLabel()
            case .success(let data):
                // special case
                if let _ = UIImage(data: data) {
                    self?.view?.setImage(with: data)
                    self?.view?.hideImageLabel()
                }
            }
            self?.view?.hideLoader()
        }
    }
    
    /// Func to get initial charcters form first name and last name
    private func configureImageLabel(with name: String) {
        let initials = name.components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.first!)") + "\($1.first!)" }
        self.view?.configureImageLabel(with: initials)
    }
}

// MARK:- ViewModel Protocol
extension ProfileViewModel: ProfileViewModelProtocol {
    func getUserData() {
        self.view?.showLoader()
        APIManager.getUserData { [weak self] (response) in
            switch response {
            case .failure(let error):
                self?.view?.displayAlert(title: "Error", message: error.localizedDescription)
            case .success(let userData):
                self?.showUserInfo(with: userData)
                guard let id = userData.id else { return }
                self?.getUserImage(with: id)
            }
            self?.view?.hideLoader()
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (2, 0):
            self.view?.displayLogOutAlert()
        case (2, 1):
            self.view?.displayDeleteAccountAlert()
        default: break
        }
    }
    
    func logOut() {
        view?.showLoader()
        APIManager.logOut { [weak self] (loggedOut) in
            if loggedOut {
                UserDefaultsManager.shared().token = nil
                self?.view?.switchToAuthState()
            } else {
                self?.view?.displayAlert(title: "Connection error", message: "Please try again later")
            }
            self?.view?.hideLoader()
        }
    }
    
    func deleteAccount() {
        view?.showLoader()
        APIManager.deleteUser { [weak self] (deleted) in
            if deleted {
                UserDefaultsManager.shared().token = nil
                self?.view?.switchToAuthState()
            }
            self?.view?.hideLoader()
        }
    }
    
    func uploadImage(with data: Data?) {
        guard let imageData = data else { return }
        view?.showLoader()
        APIManager.uploadImage(with: imageData) { [weak self] (uploaded) in
            if uploaded {
                self?.view?.setImage(with: imageData)
            } else {
                self?.view?.displayAlert(title: "Connection Error", message: "Please try again later")
            }
            self?.view?.hideLoader()
        }
    }
    
    func deleteUserImage() {
        view?.showLoader()
        APIManager.deleteUserImage { [weak self] (deleted) in
            if deleted {
                self?.view?.showImageLabel()
                self?.view?.removeImage()
            } else {
                self?.view?.hideImageLabel()
            }
            self?.view?.hideLoader()
        }
    }
    
    func updateUserInfo(name: String?, age: String?, email: String?) {
        let validName: String? = nameToUpdate(name)
        let validEmail: String? = emailToUpdate(email)
        let validAge: Int? = ageToUpdate(age)
        let user = UserData(name: validName, email: validEmail, age: validAge)
        
        view?.showLoader()
        APIManager.updateUserProfile(user) { [weak self] (updated) in
            if updated {
                self?.getUserData()
            } else {
                self?.view?.displayAlert(title: "Connection error", message: "Please try again later")
            }
            self?.view?.hideLoader()
        }
    }
}
