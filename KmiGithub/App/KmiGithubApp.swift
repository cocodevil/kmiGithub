//
//  KmiGithubApp.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import SwiftUI

@main
struct KmiGithubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(store.state.theme.colorScheme)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ZStack {
            if store.state.auth.isAuthenticated || store.state.auth.isGuest {
                MainTabView()
            } else {
                LoginView()
            }

            if store.state.error.showError {
                ErrorOverlayView()
            }
        }
        .onAppear {
            store.dispatch(.restoreSession)
        }
    }
}
