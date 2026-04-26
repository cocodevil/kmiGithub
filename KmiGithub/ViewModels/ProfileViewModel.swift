//
//  ProfileViewModel.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    @Published var repos: [Repository] = []
    @Published var isLoadingRepos = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true

    weak var store: AppStore?
    private let service = GitHubService.shared
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1

    var currentUser: GitHubUser? {
        store?.state.user.currentUser
    }

    var isAuthenticated: Bool {
        store?.state.auth.isAuthenticated ?? false
    }

    func fetchRepos() {
        guard let username = currentUser?.login else { return }
        guard !isLoadingRepos else { return }
        currentPage = 1
        isLoadingRepos = true
        errorMessage = nil

        service.fetchUserRepos(username: username, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingRepos = false
                    if case .failure = completion {
                        self?.errorMessage = NSLocalizedString("error.network", comment: "")
                    }
                },
                receiveValue: { [weak self] repos in
                    guard let self else { return }
                    self.repos = repos
                    self.hasMorePages = repos.count >= AppConstants.perPage
                }
            )
            .store(in: &cancellables)
    }

    func loadNextPage() {
        guard let username = currentUser?.login else { return }
        guard !isLoadingRepos, hasMorePages else { return }
        currentPage += 1
        isLoadingRepos = true

        service.fetchUserRepos(username: username, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingRepos = false
                    if case .failure = completion {
                        self?.errorMessage = NSLocalizedString("error.network", comment: "")
                    }
                },
                receiveValue: { [weak self] repos in
                    guard let self else { return }
                    self.repos.append(contentsOf: repos)
                    self.hasMorePages = repos.count >= AppConstants.perPage
                }
            )
            .store(in: &cancellables)
    }

    func logout() {
        store?.dispatch(.logout)
        repos = []
    }
}
