//
//  UserReducer.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation

func userReducer(state: UserState, action: AppAction) -> UserState {
    var newState = state

    switch action {
    case .fetchUserStarted:
        newState.isLoading = true

    case .fetchUserSuccess(let user):
        newState.currentUser = user
        newState.isLoading = false

    case .fetchUserFailed:
        newState.isLoading = false

    case .logout:
        newState.currentUser = nil
        newState.isLoading = false

    default:
        break
    }

    return newState
}
