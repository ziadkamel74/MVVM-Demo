//
//  ToDoListPresenter.swift
//  TODOApp-MVP-Demo
//
//  Created by Ziad on 11/21/20.
//  Copyright © 2020 IDEAEG. All rights reserved.
//

import Foundation

protocol ToDoListViewModelProtocol {
    var tasks: [TaskData] { get set }
    func getAllTasks()
    func newToDo(description: String?)
    func deleteTapped(with indexPath: IndexPath)
    func deleteTask(with id: String)
}

class ToDoListViewModel {
    // MARK:- Properties
    private weak var view: ToDoListVCProtocol?
    var tasks: [TaskData] = []
    
    // MARK:- Init
    init(view: ToDoListVC) {
        self.view = view
    }
}

// MARK:- Private Methods
extension ToDoListViewModel {
    private func saveNewTask(_ task: TaskData) {
        self.view?.showLoader()
        APIManager.addNewTask(with: task) { [weak self] (succeeded) in
            if succeeded {
                self?.getAllTasks()
            } else {
                self?.view?.displayAlert(title: "Connection error", message: "Please try again later")
            }
            self?.view?.hideLoader()
        }
    }
}

// MARK:- ViewModel Protocol
extension ToDoListViewModel: ToDoListViewModelProtocol {
    func getAllTasks() {
        view?.showLoader()
        APIManager.getAllTasks { [weak self] (response) in
            switch response {
            case .failure(let error):
                self?.view?.displayAlert(title: "Error", message: error.localizedDescription)
            case .success(let tasks):
                self?.tasks = tasks.data
                self?.view?.reloadTableView()
            }
            self?.view?.hideLoader()
        }
    }
    
    func newToDo(description: String?) {
        guard let description = description, !description.isEmpty else {
            view?.displayAlert(title: "Can't save task", message: "Please enter task description")
            return
        }
        let task = TaskData(description: description, id: nil)
        saveNewTask(task)
    }
    
    func deleteTapped(with indexPath: IndexPath) {
        if let taskID = tasks[indexPath.row].id {
            view?.displayDeleteAlert(with: taskID)
        }
    }
    
    func deleteTask(with id: String) {
        self.view?.showLoader()
        APIManager.deleteTask(with: id) { [weak self] (deleted) in
            if deleted {
                self?.getAllTasks()
            } else {
                self?.view?.displayAlert(title: "Connection error", message: "Please try again later")
            }
            self?.view?.hideLoader()
        }
    }
}
