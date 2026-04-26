//
//  AuthMiddleware.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import Combine

private var middlewareCancellables = Set<AnyCancellable>()

let authMiddleware: Middleware = { state, action, dispatch in
    switch action {
    case .loginSuccess(let token):
        KeychainService.save(token: token)
        let service = GitHubService.shared
        service.updateToken(token)
        dispatch(.fetchUserStarted)
        service.fetchCurrentUser()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        dispatch(.fetchUserFailed(error: AppError.from(error)))
                    }
                },
                receiveValue: { user in
                    dispatch(.fetchUserSuccess(user: user))
                }
            )
            .store(in: &middlewareCancellables)

    case .restoreSession:
        if let token = KeychainService.loadToken() {
            let service = GitHubService.shared
            service.updateToken(token)
            dispatch(.loginSuccess(token: token))
        }

    case .logout:
        KeychainService.deleteToken()
        GitHubService.shared.updateToken(nil)

    default:
        break
    }
}
