//
//  User.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation

struct GitHubUser: Codable, Identifiable, Equatable {
    let id: Int
    let login: String
    let avatarUrl: String
    let htmlUrl: String
    let name: String?
    let company: String?
    let blog: String?
    let location: String?
    let email: String?
    let bio: String?
    let publicRepos: Int?
    let publicGists: Int?
    let followers: Int?
    let following: Int?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, login, name, company, blog, location, email, bio, followers, following
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
        case createdAt = "created_at"
    }
}
