//
//  AppState.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import SwiftUI

enum AppTheme: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var displayName: String {
        switch self {
        case .system: return NSLocalizedString("theme.system", comment: "")
        case .light: return NSLocalizedString("theme.light", comment: "")
        case .dark: return NSLocalizedString("theme.dark", comment: "")
        }
    }

    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

struct AppState {
    var auth: AuthState
    var user: UserState
    var error: ErrorState
    var theme: AppTheme

    init() {
        self.auth = AuthState()
        self.user = UserState()
        self.error = ErrorState()
        let savedTheme = UserDefaults.standard.integer(forKey: "app_theme")
        self.theme = AppTheme(rawValue: savedTheme) ?? .system
    }
}

struct AuthState {
    var isAuthenticated: Bool = false
    var isGuest: Bool = false
    var accessToken: String? = nil
    var isLoading: Bool = false
}

struct UserState {
    var currentUser: GitHubUser? = nil
    var isLoading: Bool = false
}

struct ErrorState {
    var currentError: AppError? = nil
    var showError: Bool = false
}

enum AppError: Error, Equatable, LocalizedError {
    case networkError(String)
    case authError(String)
    case serverError(String)
    case unknownError(String)
    case userCancelled

    var isSilent: Bool {
        if case .userCancelled = self { return true }
        return false
    }

    var errorDescription: String? {
        switch self {
        case .networkError(let msg): return msg
        case .authError(let msg): return msg
        case .serverError(let msg): return msg
        case .unknownError(let msg): return msg
        case .userCancelled: return nil
        }
    }

    static func from(_ networkError: NetworkError) -> AppError {
        switch networkError {
        case .networkError(let urlError):
            return .networkError(urlError.localizedDescription)
        case .serverError(let message, _, _):
            return .serverError(message)
        case .invalidStatusCode(let code):
            return .serverError("HTTP \(code)")
        default:
            return .unknownError(networkError.errorDescription ?? "未知错误")
        }
    }
}
