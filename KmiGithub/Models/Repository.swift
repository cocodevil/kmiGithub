//
//  Repository.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation

struct Repository: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let fullName: String
    let owner: RepositoryOwner
    let htmlUrl: String
    let description: String?
    let fork: Bool
    let language: String?
    let stargazersCount: Int
    let watchersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let defaultBranch: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, owner, description, fork, language
        case fullName = "full_name"
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case defaultBranch = "default_branch"
        case updatedAt = "updated_at"
    }
}

struct RepositoryOwner: Codable, Equatable {
    let id: Int
    let login: String
    let avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case id, login
        case avatarUrl = "avatar_url"
    }
}
