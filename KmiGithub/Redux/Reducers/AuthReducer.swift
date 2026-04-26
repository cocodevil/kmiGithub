//
//  AuthReducer.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation

func authReducer(state: AuthState, action: AppAction) -> AuthState {
    var newState = state

    switch action {
    case .loginStarted:
        newState.isLoading = true

    case .loginSuccess(let token):
        newState.isAuthenticated = true
        newState.isGuest = false
        newState.accessToken = token
        newState.isLoading = false

    case .loginFailed:
        newState.isLoading = false

    case .logout:
        newState.isAuthenticated = false
        newState.isGuest = false
        newState.accessToken = nil
        newState.isLoading = false

    case .enterGuest:
        newState.isGuest = true
        newState.isAuthenticated = false
        newState.accessToken = nil
        newState.isLoading = false

    default:
        break
    }

    return newState
}
