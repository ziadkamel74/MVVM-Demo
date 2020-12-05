//
//  ProfileTableVC.swift
//  TODOApp-MVC-Demo
//
//  Created by Ziad on 11/5/20.
//  Copyright © 2020 IDEAEG. All rights reserved.
//

import UIKit

protocol MainNavigationDelegate: class {
    func showAuthState()
}

protocol ProfileVCProtocol: class {
    func switchToAuthState()
    func showLoader()
    func hideLoader()
    func displayAlert(title: String, message: String)
    func showImageLabel()
    func hideImageLabel()
    func setImage(with data: Data)
    func removeImage()
    func showUserInfo(_ name: String, _ email: String, _ age: String)
    func configureImageLabel(with initials: String)
    func displayLogOutAlert()
    func displayDeleteAccountAlert()
}

class ProfileVC: UITableViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var userImageBtn: UIButton!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    // MARK:- Properties
    var viewModel: ProfileViewModelProtocol!
    weak var delegate: MainNavigationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        viewModel.getUserData()
    }
    
    // MARK:- Public Methods
    class func create() -> ProfileVC {
        let profileVC: ProfileVC = UIViewController.create(storyboardName: Storyboards.main, identifier: ViewControllers.profileVC)
        profileVC.delegate = AppStateManager.shared
        profileVC.viewModel = ProfileViewModel(view: profileVC)
        return profileVC
    }
}

extension ProfileVC {
    // MARK:- Private Methods
    private func setupViews() {
        setupNavBar()
        setupImageButton()
    }
    
    private func setupImageButton() {
        userImageBtn.addTarget(self, action: #selector(displayImageAlert), for: .touchUpInside)
        userImageBtn.layer.cornerRadius = userImageBtn.frame.width / 2
        userImageBtn.layer.masksToBounds = true
    }
    
    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit Info", style: .done, target: self, action: #selector(displayEditAlert))
    }
    
    private func presentImagePicker() {
        // Picker instance
        let picker = UIImagePickerController()
        // Allow image cropping
        picker.allowsEditing = true
        // Setting delegate to self, delegation design pattern require conforming protocols
        picker.delegate = self
        // Presenting the image picker
        self.present(picker, animated: true, completion: nil)
    }
    
    // MARK:- objc Methods
    @objc private func displayImageAlert() {
        let photoAlert = UIAlertController(title: "Profile Picture", message: nil, preferredStyle: .actionSheet)
        photoAlert.addAction(UIAlertAction(title: "Choose from Photo Library", style: .default, handler: { [weak self] (action) in
            self?.presentImagePicker()
        }))
        photoAlert.addAction(UIAlertAction(title: "Delete Picture", style: .destructive, handler: { [weak self] (action) in
            self?.viewModel.deleteUserImage()
        }))
        photoAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(photoAlert, animated: true)
    }
    
    @objc private func displayEditAlert() {
        let editAlert = UIAlertController(title: "Edit Info", message: nil, preferredStyle: .alert)
        editAlert.addTextField { (textField) in
            textField.placeholder = "Name..."
        }
        editAlert.addTextField { (textField) in
            textField.placeholder = "Age..."
            textField.keyboardType = .numberPad
        }
        editAlert.addTextField { (textField) in
            textField.placeholder = "Email..."
            textField.keyboardType = .emailAddress
        }
        editAlert.addAction(UIAlertAction(title: "Save", style: .destructive, handler: { [weak self] (action) in
            
            let name = editAlert.textFields?[0].text, age = editAlert.textFields?[1].text, email = editAlert.textFields?[2].text
            self?.viewModel.updateUserInfo(name: name, age: age, email: email)
            
        }))
        editAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(editAlert, animated: true)
    }
}

// MARK:- TableView Delegate
extension ProfileVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectRow(at: indexPath)
    }
}

// MARK:- ImagePicker Delegate
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
        let imageData = image?.jpegData(compressionQuality: 0.5)
        picker.dismiss(animated: true, completion: nil)
        viewModel.uploadImage(with: imageData)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss picker when user cancel
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK:- ProfileVC Protocol
extension ProfileVC: ProfileVCProtocol {
    func switchToAuthState() {
        delegate?.showAuthState()
    }
    
    func showLoader() {
        self.view.showLoader()
    }
    
    func hideLoader() {
        self.view.hideLoader()
    }
    
    func displayAlert(title: String, message: String) {
        showAlert(title: title, message: message)
    }
    
    func showImageLabel() {
        imageLabel.isHidden = false
    }
    
    func hideImageLabel() {
        imageLabel.isHidden = true
    }
    
    func setImage(with data: Data) {
        userImageBtn.setImage(UIImage(data: data), for: .normal)
    }
    
    func removeImage() {
        userImageBtn.setImage(UIImage(), for: .normal)
    }
    
    func showUserInfo(_ name: String, _ email: String, _ age: String) {
        nameLabel.text = name
        ageLabel.text = age
        emailLabel.text = email
    }
    
    func configureImageLabel(with initials: String) {
        imageLabel.text = initials
    }
    
    func displayLogOutAlert() {
        let logOutAlert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        logOutAlert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] (action) in
            self?.viewModel.logOut()
        }))
        
        logOutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(logOutAlert, animated: true)
    }
    
    func displayDeleteAccountAlert() {
        let deleteAccAlert = UIAlertController(title: "Delete your Account", message: "Are you sure you want to delete your account?", preferredStyle: .actionSheet)
        deleteAccAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (action) in
            self?.viewModel.deleteAccount()
        }))
        
        deleteAccAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(deleteAccAlert, animated: true)
    }
}
