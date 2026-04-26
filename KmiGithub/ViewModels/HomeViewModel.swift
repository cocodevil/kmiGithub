//
//  HomeViewModel.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var trendingRepos: [Repository] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true

    private let service = GitHubService.shared
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1

    func fetchTrendingRepos() {
        guard !isLoading else { return }
        currentPage = 1
        isLoading = true
        errorMessage = nil

        service.fetchTrendingRepos(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure = completion {
                        self?.errorMessage = NSLocalizedString("error.network", comment: "")
                    }
                },
                receiveValue: { [weak self] result in
                    guard let self else { return }
                    self.trendingRepos = result.items
                    self.hasMorePages = result.items.count >= AppConstants.perPage
                }
            )
            .store(in: &cancellables)
    }

    func loadNextPage() {
        guard !isLoading, hasMorePages else { return }
        currentPage += 1
        isLoading = true

        service.fetchTrendingRepos(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure = completion {
                        self?.errorMessage = NSLocalizedString("error.network", comment: "")
                    }
                },
                receiveValue: { [weak self] result in
                    guard let self else { return }
                    self.trendingRepos.append(contentsOf: result.items)
                    self.hasMorePages = result.items.count >= AppConstants.perPage
                }
            )
            .store(in: &cancellables)
    }
}
