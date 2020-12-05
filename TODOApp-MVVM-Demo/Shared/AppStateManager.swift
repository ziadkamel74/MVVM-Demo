//
//  AppStateManager.swift
//  TODOApp-MVP-Demo
//
//  Created by Ziad on 12/4/20.
//  Copyright © 2020 IDEAEG. All rights reserved.
//

import Foundation

protocol AppStateManagerProtocol {
    func start(appDelegate: AppDelegateProtocol)
}

class AppStateManager {
    
    // MARK:- AppState Enum
    private enum AppState {
        case none
        case auth
        case main
    }
    
    // MARK:- Singleton
    static let shared = AppStateManager()
    private init() {}

    // MARK:- Properties
    private var appDelegate: AppDelegateProtocol!
    private var state: AppState = .none {
        willSet(newState) {
            switch newState {
            case .auth:
                switchToAuthState()
            case .main:
                switchToMainState()
            case .none:
                break
            }
        }
    }
}

// MARK:- Private Methods
extension AppStateManager {
    private func switchToMainState() {
        let toDoListVC = ToDoListVC.create()
        let navigationController = appDelegate.getNavController()
        navigationController.viewControllers = [toDoListVC]
        self.appDelegate.getMainWindow()?.rootViewController = navigationController
    }
    
    private func switchToAuthState() {
        let signInVC = SignInVC.create()
        let navigationController = appDelegate.getNavController()
        navigationController.viewControllers = [signInVC]
        self.appDelegate.getMainWindow()?.rootViewController = navigationController
    }
}

// MARK:- AppStateManager Protocol
extension AppStateManager: AppStateManagerProtocol {
    func start(appDelegate: AppDelegateProtocol) {
        self.appDelegate = appDelegate
        if UserDefaultsManager.shared().token != nil {
            state = .main
        } else {
            state = .auth
        }
    }
}

// MARK:- Navigation Delegate
extension AppStateManager: AuthNavigationDelegate, MainNavigationDelegate {
    func showMainState() {
        state = .main
    }
    
    func showAuthState() {
        state = .auth
    }
}
