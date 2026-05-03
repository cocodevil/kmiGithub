//
//  HomeView.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.trendingRepos.isEmpty && viewModel.isLoading {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage, viewModel.trendingRepos.isEmpty {
                    InlineErrorView(message: errorMessage) {
                        viewModel.fetchTrendingRepos()
                    }
                } else if viewModel.trendingRepos.isEmpty {
                    EmptyStateView(
                        icon: "star",
                        title: NSLocalizedString("home.empty.title", comment: ""),
                        message: NSLocalizedString("home.empty.message", comment: "")
                    )
                } else {
                    repoList
                }
            }
            .navigationTitle(NSLocalizedString("tab.home", comment: ""))
        }
        .navigationViewStyle(.stack)
        .onAppear {
            if viewModel.trendingRepos.isEmpty {
                viewModel.fetchTrendingRepos()
            }
        }
    }

    private var repoList: some View {
        List {
            ForEach(viewModel.trendingRepos) { repo in
                NavigationLink(destination: RepositoryDetailView(repository: repo)) {
                    RepositoryRowView(repository: repo)
                        .onAppear {
                            if repo.id == viewModel.trendingRepos.last?.id {
                                viewModel.loadNextPage()
                            }
                        }
                }
            }

            if viewModel.isLoading && !viewModel.trendingRepos.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}
