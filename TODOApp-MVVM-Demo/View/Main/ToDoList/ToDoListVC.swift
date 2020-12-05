//
//  ViewController.swift
//  TODOApp-MVC-Demo
//
//  Created by IDEAcademy on 10/27/20.
//  Copyright © 2020 IDEAEG. All rights reserved.
//

import UIKit

protocol ToDoListVCProtocol: class {
    func showLoader()
    func hideLoader()
    func displayAlert(title: String, message: String)
    func reloadTableView()
    func displayDeleteAlert(with taskID: String)
}

class ToDoListVC: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var mainView: ToDoListView!
    
    // MARK:- Properties
    var viewModel: ToDoListViewModelProtocol!
    
    // MARK:- LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.setup()
        setupViews()
        viewModel.getAllTasks()
    }

    // MARK:- Public Methods
    class func create() -> ToDoListVC {
        let toDoListVC: ToDoListVC = UIViewController.create(storyboardName: Storyboards.main, identifier: ViewControllers.toDoListVC)
        toDoListVC.viewModel = ToDoListViewModel(view: toDoListVC)
        return toDoListVC
    }
}

extension ToDoListVC {
    // MARK:- Private Methods
    private func setupViews() {
        setupNavBar()
        setupTableView()
    }
    
    private func setupNavBar() {
        navigationItem.title = "Tasks"
        let newTaskButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(displayNewTodoAlert))
        newTaskButton.tintColor = .label
        let profileButton = UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: #selector(profileButtonTapped))
        profileButton.tintColor = .label
        navigationItem.rightBarButtonItems = [newTaskButton, profileButton]
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    private func setupTableView() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
    }
    
    // MARK:- @Objc Methods
    @objc private func displayNewTodoAlert() {
        let alert = UIAlertController(title: "Add New Task", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Description"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] (action) in
            self?.viewModel.newToDo(description: alert.textFields?.first?.text)
        }))
        present(alert, animated: true)
    }
    
    @objc private func profileButtonTapped() {
        let profileTableVC = ProfileVC.create()
        navigationController?.pushViewController(profileTableVC, animated: true)
    }
}

// MARK:- TableView DataSource and Delegate
extension ToDoListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cells.toDoCell, for: indexPath) as? ToDoCell else {
            return UITableViewCell()
        }
        cell.configure(description: viewModel.tasks[indexPath.row].description)
        cell.deletion = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}


// MARK:- Task Deletion Delegate
extension ToDoListVC: DeleteTask {
    func deleteTapped(sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: mainView.tableView)
        guard let indexPath = mainView.tableView.indexPathForRow(at: hitPoint) else { return }
        viewModel.deleteTapped(with: indexPath)
    }
}

// MARK:- ToDoList Protocol
extension ToDoListVC: ToDoListVCProtocol {
    func showLoader() {
        self.mainView.showLoader()
    }
    
    func hideLoader() {
        self.mainView.hideLoader()
    }
    
    func displayAlert(title: String, message: String) {
        showAlert(title: title, message: message)
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.mainView.tableView.reloadData()
        }
    }
    
    func displayDeleteAlert(with taskID: String) {
        let alert = UIAlertController(title: "Sorry", message: "Are you sure you want to delete this todo?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] action in
            self?.viewModel.deleteTask(with: taskID)
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true)
    }
}
