//
//  AppDelegate.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme == AppConstants.oauthCallbackScheme {
            NotificationCenter.default.post(name: .oauthCallback, object: url)
            return true
        }
        return false
    }
}

extension Notification.Name {
    static let oauthCallback = Notification.Name("OAuthCallbackNotification")
}

