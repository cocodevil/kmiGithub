//
//  ModelDecodingTests.swift
//  KmiGithubTests
//
//  Created by Renzhong Xu on 2026/4/26.
//

import XCTest
@testable import KmiGithub

final class ModelDecodingTests: XCTestCase {

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    func testUserDecoding() throws {
        let json = """
        {
            "id": 12345,
            "login": "octocat",
            "avatar_url": "https://avatars.githubusercontent.com/u/583231",
            "html_url": "https://github.com/octocat",
            "name": "The Octocat",
            "bio": "GitHub mascot",
            "public_repos": 8,
            "public_gists": 8,
            "followers": 10000,
            "following": 9,
            "created_at": "2011-01-25T18:44:36Z"
        }
        """.data(using: .utf8)!

        let user = try decoder.decode(GitHubUser.self, from: json)

        XCTAssertEqual(user.id, 12345)
        XCTAssertEqual(user.login, "octocat")
        XCTAssertEqual(user.name, "The Octocat")
        XCTAssertEqual(user.bio, "GitHub mascot")
        XCTAssertEqual(user.followers, 10000)
    }

    func testRepositoryDecoding() throws {
        let json = """
        {
            "id": 1296269,
            "name": "Hello-World",
            "full_name": "octocat/Hello-World",
            "owner": {
                "id": 1,
                "login": "octocat",
                "avatar_url": "https://avatars.githubusercontent.com/u/1"
            },
            "html_url": "https://github.com/octocat/Hello-World",
            "description": "My first repository on GitHub!",
            "fork": false,
            "language": "Swift",
            "stargazers_count": 1234,
            "watchers_count": 1234,
            "forks_count": 567,
            "open_issues_count": 12,
            "default_branch": "main",
            "updated_at": "2024-01-01T00:00:00Z"
        }
        """.data(using: .utf8)!

        let repo = try decoder.decode(Repository.self, from: json)

        XCTAssertEqual(repo.id, 1296269)
        XCTAssertEqual(repo.name, "Hello-World")
        XCTAssertEqual(repo.fullName, "octocat/Hello-World")
        XCTAssertEqual(repo.owner.login, "octocat")
        XCTAssertEqual(repo.language, "Swift")
        XCTAssertEqual(repo.stargazersCount, 1234)
        XCTAssertEqual(repo.forksCount, 567)
        XCTAssertFalse(repo.fork)
    }

    func testSearchResultDecoding() throws {
        let json = """
        {
            "total_count": 1,
            "incomplete_results": false,
            "items": [
                {
                    "id": 1,
                    "name": "test",
                    "full_name": "user/test",
                    "owner": {
                        "id": 1,
                        "login": "user",
                        "avatar_url": "https://example.com/avatar.png"
                    },
                    "html_url": "https://github.com/user/test",
                    "description": "A test repo",
                    "fork": false,
                    "language": "Python",
                    "stargazers_count": 100,
                    "watchers_count": 100,
                    "forks_count": 10,
                    "open_issues_count": 5,
                    "default_branch": "main",
                    "updated_at": "2024-01-01T00:00:00Z"
                }
            ]
        }
        """.data(using: .utf8)!

        let result = try decoder.decode(SearchResult.self, from: json)

        XCTAssertEqual(result.totalCount, 1)
        XCTAssertFalse(result.incompleteResults)
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.name, "test")
    }

    func testAccessTokenResponseDecoding() throws {
        let json = """
        {
            "access_token": "gho_abc123",
            "token_type": "bearer",
            "scope": "user,repo"
        }
        """.data(using: .utf8)!

        let token = try decoder.decode(AccessTokenResponse.self, from: json)

        XCTAssertEqual(token.accessToken, "gho_abc123")
        XCTAssertEqual(token.tokenType, "bearer")
        XCTAssertEqual(token.scope, "user,repo")
    }
}
