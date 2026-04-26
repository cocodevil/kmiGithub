//
//  AppAction.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation

enum AppAction {
    // Auth
    case loginStarted
    case loginSuccess(token: String)
    case loginFailed(error: AppError)
    case logout
    case enterGuest
    case restoreSession

    // User
    case fetchUserStarted
    case fetchUserSuccess(user: GitHubUser)
    case fetchUserFailed(error: AppError)

    // Error
    case showError(AppError)
    case dismissError

    // Theme
    case setTheme(AppTheme)
}
