//
//  AppConstants.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation

enum AppConstants {
    static let githubClientID = "Ov23liws42sn58gYhGPJ"
    static let githubClientSecret = "c7ac36625fa00c4cbf3365bbd7236d5b7934a201"
    static let oauthCallbackScheme = "kmigithub"
    static let oauthCallbackURL = "kmigithub://oauth/callback"
    static let githubBaseURL = "https://api.github.com"
    static let githubAuthURL = "https://github.com/login/oauth/authorize"
    static let githubTokenURL = "https://github.com/login/oauth/access_token"

    static let keychainTokenKey = "github_access_token"
    static let perPage = 20
}
