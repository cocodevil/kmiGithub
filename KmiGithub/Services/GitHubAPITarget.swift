//
//  GitHubAPITarget.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import Moya
import Alamofire

enum GitHubAPITarget {
    case accessToken(code: String)
    case currentUser
    case userProfile(username: String)
    case userRepos(username: String, page: Int, perPage: Int)
    case searchRepos(query: String, sort: String, page: Int, perPage: Int)
    case trendingRepos(page: Int, perPage: Int)
    case starRepo(owner: String, repo: String)
    case unstarRepo(owner: String, repo: String)
    case checkStarred(owner: String, repo: String)
}

extension GitHubAPITarget: TargetType {

    var baseURL: URL {
        switch self {
        case .accessToken:
            return URL(string: "https://github.com")!
        default:
            return URL(string: AppConstants.githubBaseURL)!
        }
    }

    var path: String {
        switch self {
        case .accessToken:
            return "/login/oauth/access_token"
        case .currentUser:
            return "/user"
        case .userProfile(let username):
            return "/users/\(username)"
        case .userRepos(let username, _, _):
            return "/users/\(username)/repos"
        case .searchRepos:
            return "/search/repositories"
        case .trendingRepos:
            return "/search/repositories"
        case .starRepo(let owner, let repo),
             .unstarRepo(let owner, let repo),
             .checkStarred(let owner, let repo):
            return "/user/starred/\(owner)/\(repo)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .accessToken:
            return .post
        case .starRepo:
            return .put
        case .unstarRepo:
            return .delete
        default:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .accessToken(let code):
            return .requestParameters(parameters: [
                "client_id": AppConstants.githubClientID,
                "client_secret": AppConstants.githubClientSecret,
                "code": code
            ], encoding: JSONEncoding.default)

        case .userRepos(_, let page, let perPage):
            return .requestParameters(parameters: [
                "page": page,
                "per_page": perPage,
                "sort": "updated"
            ], encoding: URLEncoding.queryString)

        case .searchRepos(let query, let sort, let page, let perPage):
            return .requestParameters(parameters: [
                "q": query,
                "sort": sort,
                "order": "desc",
                "page": page,
                "per_page": perPage
            ], encoding: URLEncoding.queryString)

        case .trendingRepos(let page, let perPage):
            return .requestParameters(parameters: [
                "q": "stars:>1000",
                "sort": "stars",
                "order": "desc",
                "page": page,
                "per_page": perPage
            ], encoding: URLEncoding.queryString)

        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .accessToken:
            return [
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]
        default:
            return [
                "Accept": "application/vnd.github.v3+json"
            ]
        }
    }
}

