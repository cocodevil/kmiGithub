//
//  UserReducerTests.swift
//  KmiGithubTests
//
//  Created by Renzhong Xu on 2026/4/26.
//

import XCTest
@testable import KmiGithub

final class UserReducerTests: XCTestCase {

    private func makeTestUser() -> GitHubUser {
        GitHubUser(
            id: 1,
            login: "testuser",
            avatarUrl: "https://example.com/avatar.png",
            htmlUrl: "https://github.com/testuser",
            name: "Test User",
            company: nil,
            blog: nil,
            location: nil,
            email: nil,
            bio: "A test user",
            publicRepos: 10,
            publicGists: 5,
            followers: 100,
            following: 50,
            createdAt: "2020-01-01T00:00:00Z"
        )
    }

    func testFetchUserStartedSetsLoading() {
        let state = UserState()
        let newState = userReducer(state: state, action: .fetchUserStarted)

        XCTAssertTrue(newState.isLoading)
    }

    func testFetchUserSuccessSetsUser() {
        var state = UserState()
        state.isLoading = true
        let user = makeTestUser()
        let newState = userReducer(state: state, action: .fetchUserSuccess(user: user))

        XCTAssertFalse(newState.isLoading)
        XCTAssertEqual(newState.currentUser?.login, "testuser")
        XCTAssertEqual(newState.currentUser?.name, "Test User")
    }

    func testFetchUserFailedClearsLoading() {
        var state = UserState()
        state.isLoading = true
        let error = AppError.networkError("Network failed")
        let newState = userReducer(state: state, action: .fetchUserFailed(error: error))

        XCTAssertFalse(newState.isLoading)
    }

    func testLogoutClearsUser() {
        var state = UserState()
        state.currentUser = makeTestUser()
        let newState = userReducer(state: state, action: .logout)

        XCTAssertNil(newState.currentUser)
    }
}
