//
//  LoggingMiddleware.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation

let loggingMiddleware: Middleware = { state, action, _ in
    #if DEBUG
    print("[Redux] Action: \(action)")
    print("[Redux] Auth: authenticated=\(state.auth.isAuthenticated), guest=\(state.auth.isGuest)")
    #endif
}
