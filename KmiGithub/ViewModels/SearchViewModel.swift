//
//  SearchViewModel.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [Repository] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true
    @Published var totalCount = 0

    private let service = GitHubService.shared
    private var cancellables = Set<AnyCancellable>()
    private var searchCancellable: AnyCancellable?
    private var currentPage = 1

    init() {
        setupSearchDebounce()
    }

    private func setupSearchDebounce() {
        searchCancellable = $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.results = []
                    self.totalCount = 0
                    return
                }
                self.performSearch(query: query)
            }
    }

    func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        currentPage = 1
        isLoading = true
        errorMessage = nil

        service.searchRepos(query: query, page: currentPage)
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
                    self.results = result.items
                    self.totalCount = result.totalCount
                    self.hasMorePages = result.items.count >= AppConstants.perPage
                }
            )
            .store(in: &cancellables)
    }

    func loadNextPage() {
        guard !isLoading, hasMorePages else { return }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        currentPage += 1
        isLoading = true

        service.searchRepos(query: query, page: currentPage)
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
                    self.results.append(contentsOf: result.items)
                    self.hasMorePages = result.items.count >= AppConstants.perPage
                }
            )
            .store(in: &cancellables)
    }
}
