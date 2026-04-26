//
//  AppReducer.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation

func appReducer(state: AppState, action: AppAction) -> AppState {
    var newState = state
    newState.auth = authReducer(state: state.auth, action: action)
    newState.user = userReducer(state: state.user, action: action)
    newState.error = errorReducer(state: state.error, action: action)

    if case .setTheme(let theme) = action {
        newState.theme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "app_theme")
    }

    return newState
}
