//
//  ErrorReducer.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation

func errorReducer(state: ErrorState, action: AppAction) -> ErrorState {
    var newState = state

    switch action {
    case .showError(let error):
        guard !error.isSilent else { break }
        newState.currentError = error
        newState.showError = true

    case .dismissError:
        newState.currentError = nil
        newState.showError = false

    case .loginFailed(let error):
        guard !error.isSilent else { break }
        newState.currentError = error
        newState.showError = true

    case .fetchUserFailed(let error):
        guard !error.isSilent else { break }
        newState.currentError = error
        newState.showError = true

    default:
        break
    }

    return newState
}
