//
//  SignInVC.swift
//  TODOApp-MVC-Demo
//
//  Created by IDEAcademy on 10/27/20.
//  Copyright © 2020 IDEAEG. All rights reserved.
//

import UIKit

protocol AuthNavigationDelegate: class {
    func showMainState()
}

protocol AuthenticationVCsProtocol: class {
    func showLoader()
    func hideLoader()
    func displayAlert(title: String, message: String)
    func switchToMainState()
}

class SignInVC: UIViewController {

    // MARK:- Outlets
    @IBOutlet weak var mainView: SignInView!
    
    // MARK:- Properties
    var viewModel: AuthenticationViewModelProtocol!
    weak var delegate: AuthNavigationDelegate?
    
    // MARK:- LifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.setup()
    }

    // MARK:- Public Methods
    class func create() -> SignInVC {
        let signInVC: SignInVC = UIViewController.create(storyboardName: Storyboards.authentication, identifier: ViewControllers.signInVC)
        signInVC.delegate = AppStateManager.shared
        signInVC.viewModel = SignInViewModel(view: signInVC)
        return signInVC
    }
    
    // MARK:- IBAction Methods
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        viewModel.tryToLogin(with: mainView.emailTextField.text, password: mainView.passwordTextField.text)
    }
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        let signUpVC = SignUpVC.create()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
}

// MARK:- AuthVCs Protocol
extension SignInVC: AuthenticationVCsProtocol {
    func showLoader() {
        mainView.showLoader()
    }
    
    func hideLoader() {
        mainView.hideLoader()
    }
    
    func displayAlert(title: String, message: String) {
        showAlert(title: title, message: message)
    }
    
    func switchToMainState() {
        delegate?.showMainState()
    }
}
