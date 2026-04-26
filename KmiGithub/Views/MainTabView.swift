//
//  MainTabView.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(NSLocalizedString("tab.home", comment: ""), systemImage: "house.fill")
                }

            SearchView()
                .tabItem {
                    Label(NSLocalizedString("tab.search", comment: ""), systemImage: "magnifyingglass")
                }

            ProfileView()
                .tabItem {
                    Label(NSLocalizedString("tab.profile", comment: ""), systemImage: "person.fill")
                }
        }
    }
}
