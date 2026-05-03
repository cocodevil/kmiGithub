//
//  SearchView.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBarView(text: $viewModel.searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)

                Group {
                    if viewModel.searchText.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: NSLocalizedString("search.empty.title", comment: ""),
                            message: NSLocalizedString("search.empty.message", comment: "")
                        )
                    } else if viewModel.results.isEmpty && viewModel.isLoading {
                        LoadingView()
                    } else if let errorMessage = viewModel.errorMessage, viewModel.results.isEmpty {
                        InlineErrorView(message: errorMessage) {
                            viewModel.performSearch(query: viewModel.searchText)
                        }
                    } else if viewModel.results.isEmpty && !viewModel.searchText.isEmpty {
                        EmptyStateView(
                            icon: "doc.text.magnifyingglass",
                            title: NSLocalizedString("search.noresult.title", comment: ""),
                            message: NSLocalizedString("search.noresult.message", comment: "")
                        )
                    } else {
                        resultsList
                    }
                }
            }
            .navigationTitle(NSLocalizedString("tab.search", comment: ""))
        }
        .navigationViewStyle(.stack)
    }

    private var resultsList: some View {
        List {
            if viewModel.totalCount > 0 {
                Text(String(format: NSLocalizedString("search.result.count", comment: ""), viewModel.totalCount))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ForEach(viewModel.results) { repo in
                NavigationLink(destination: RepositoryDetailView(repository: repo)) {
                    RepositoryRowView(repository: repo)
                        .onAppear {
                            if repo.id == viewModel.results.last?.id {
                                viewModel.loadNextPage()
                            }
                        }
                }
            }

            if viewModel.isLoading && !viewModel.results.isEmpty {
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

struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(NSLocalizedString("search.placeholder", comment: ""), text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
