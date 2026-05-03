//
//  ProfileView.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationView {
            Group {
                if store.state.auth.isAuthenticated {
                    authenticatedContent
                } else {
                    guestContent
                }
            }
            .navigationTitle(NSLocalizedString("tab.profile", comment: ""))
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.store = store
            if store.state.auth.isAuthenticated && viewModel.repos.isEmpty {
                viewModel.fetchRepos()
            }
        }
    }

    private var authenticatedContent: some View {
        List {
            if let user = store.state.user.currentUser {
                Section {
                    ProfileHeaderView(user: user)
                        .listRowInsets(EdgeInsets())
                }
            }

            if store.state.user.isLoading && viewModel.repos.isEmpty {
                Section {
                    LoadingView()
                        .frame(height: 200)
                }
            } else if let errorMessage = viewModel.errorMessage, viewModel.repos.isEmpty {
                Section {
                    InlineErrorView(message: errorMessage) {
                        viewModel.fetchRepos()
                    }
                    .frame(height: 200)
                }
            } else {
                Section(header: Text(NSLocalizedString("profile.repos", comment: ""))) {
                    ForEach(viewModel.repos) { repo in
                        NavigationLink(destination: RepositoryDetailView(repository: repo)) {
                            RepositoryRowView(repository: repo)
                                .onAppear {
                                    if repo.id == viewModel.repos.last?.id {
                                        viewModel.loadNextPage()
                                    }
                                }
                        }
                    }

                    if viewModel.isLoadingRepos && !viewModel.repos.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
            }

            Section(header: Text(NSLocalizedString("settings.title", comment: ""))) {
                ThemeSelectorView()
            }

            Section {
                Button(action: {
                    viewModel.logout()
                }) {
                    HStack {
                        Spacer()
                        Text(NSLocalizedString("profile.logout", comment: ""))
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    private var guestContent: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)

                    Text(NSLocalizedString("profile.guest.title", comment: ""))
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(NSLocalizedString("profile.guest.message", comment: ""))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button {
                        store.dispatch(.logout)
                    } label: {
                        Text(NSLocalizedString("profile.guest.login", comment: ""))
                            .fontWeight(.semibold)
                            .frame(maxWidth: 200)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }

            Section(header: Text(NSLocalizedString("settings.title", comment: ""))) {
                ThemeSelectorView()
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}
