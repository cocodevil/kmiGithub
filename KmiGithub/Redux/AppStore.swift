//
//  AppStore.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import Combine

typealias Reducer = (AppState, AppAction) -> AppState
typealias Middleware = (AppState, AppAction, @escaping (AppAction) -> Void) -> Void

final class AppStore: ObservableObject {
    @Published private(set) var state: AppState

    private let reducer: Reducer
    private let middlewares: [Middleware]
    private var cancellables = Set<AnyCancellable>()

    init(
        initialState: AppState = AppState(),
        reducer: @escaping Reducer = appReducer,
        middlewares: [Middleware] = [authMiddleware, loggingMiddleware]
    ) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
    }

    func dispatch(_ action: AppAction) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.state = self.reducer(self.state, action)

            for middleware in self.middlewares {
                middleware(self.state, action) { [weak self] newAction in
                    self?.dispatch(newAction)
                }
            }
        }
    }
}
