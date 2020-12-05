//
//  SignUpVC.swift
//  TODOApp-MVC-Demo
//
//  Created by IDEAcademy on 10/27/20.
//  Copyright © 2020 IDEAEG. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var mainView: SignUpView!
    
    // MARK:- Properties
    var viewModel: AuthenticationViewModelProtocol!
    weak var delegate: AuthNavigationDelegate?
    
    // MARK:- LifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.setup()
    }

    // MARK:- Public Methods
    class func create() -> SignUpVC {
        let signUpVC: SignUpVC = UIViewController.create(storyboardName: Storyboards.authentication, identifier: ViewControllers.signUpVC)
        signUpVC.delegate = AppStateManager.shared
        signUpVC.viewModel = SignUpViewModel(view: signUpVC)
        return signUpVC
    }
    
    // MARK:- IBAction Methods
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        viewModel.tryToRegister(name: mainView.nameTextField.text, email: mainView.emailTextField.text, password: mainView.passwordTextField.text, age: mainView.ageTextField.text)
    }
}

// MARK:- AuthVCs Protocol
extension SignUpVC: AuthenticationVCsProtocol {
    func showLoader() {
        self.view.showLoader()
    }
    
    func hideLoader() {
        self.view.hideLoader()
    }
    
    func displayAlert(title: String, message: String) {
        showAlert(title: title, message: message)
    }
    
    func switchToMainState() {
        delegate?.showMainState()
    }
}
