//
//  GitHubService.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import Combine
import Moya

final class TokenStore {
    var token: String?
}

final class GitHubService {
    static let shared = GitHubService()

    private let tokenStore = TokenStore()
    private let networkManager: NetworkManager<GitHubAPITarget>

    private init() {
        let store = tokenStore

        let endpointClosure = { (target: GitHubAPITarget) -> Endpoint in
            let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
            guard let token = store.token, !token.isEmpty else {
                return defaultEndpoint
            }
            return defaultEndpoint.adding(newHTTPHeaderFields: [
                "Authorization": "Bearer \(token)"
            ])
        }

        let provider = MoyaProvider<GitHubAPITarget>(
            endpointClosure: endpointClosure,
            plugins: [
                NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
            ]
        )

        self.networkManager = NetworkManager<GitHubAPITarget>(
            provider: provider,
            errorHandler: DefaultErrorHandler()
        )
    }

    func updateToken(_ token: String?) {
        tokenStore.token = token
    }

    // MARK: - Auth

    func exchangeToken(code: String) -> AnyPublisher<AccessTokenResponse, NetworkError> {
        networkManager.requestReturnModel(
            .accessToken(code: code),
            responseType: AccessTokenResponse.self
        )
    }

    // MARK: - User

    func fetchCurrentUser() -> AnyPublisher<GitHubUser, NetworkError> {
        networkManager.requestReturnModel(
            .currentUser,
            responseType: GitHubUser.self
        )
    }

    func fetchUserProfile(username: String) -> AnyPublisher<GitHubUser, NetworkError> {
        networkManager.requestReturnModel(
            .userProfile(username: username),
            responseType: GitHubUser.self
        )
    }

    // MARK: - Repos

    func fetchUserRepos(username: String, page: Int = 1) -> AnyPublisher<[Repository], NetworkError> {
        networkManager.requestReturnModel(
            .userRepos(username: username, page: page, perPage: AppConstants.perPage),
            responseType: [Repository].self
        )
    }

    func searchRepos(query: String, sort: String = "stars", page: Int = 1) -> AnyPublisher<SearchResult, NetworkError> {
        networkManager.requestReturnModel(
            .searchRepos(query: query, sort: sort, page: page, perPage: AppConstants.perPage),
            responseType: SearchResult.self
        )
    }

    func fetchTrendingRepos(page: Int = 1) -> AnyPublisher<SearchResult, NetworkError> {
        networkManager.requestReturnModel(
            .trendingRepos(page: page, perPage: AppConstants.perPage),
            responseType: SearchResult.self
        )
    }

    // MARK: - Star

    func starRepo(owner: String, repo: String) -> AnyPublisher<Void, Error> {
        networkManager.requestReturnData(.starRepo(owner: owner, repo: repo))
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func unstarRepo(owner: String, repo: String) -> AnyPublisher<Void, Error> {
        networkManager.requestReturnData(.unstarRepo(owner: owner, repo: repo))
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
