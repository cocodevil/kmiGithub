//
//  AppReducerTests.swift
//  KmiGithubTests
//
//  Created by Renzhong Xu on 2026/4/26.
//

import XCTest
@testable import KmiGithub

final class AppReducerTests: XCTestCase {

    func testAppReducerCombinesAllReducers() {
        let state = AppState()
        let newState = appReducer(state: state, action: .loginStarted)

        XCTAssertTrue(newState.auth.isLoading)
        XCTAssertFalse(newState.user.isLoading)
        XCTAssertFalse(newState.error.showError)
    }

    func testFullLoginFlow() {
        var state = AppState()

        state = appReducer(state: state, action: .loginStarted)
        XCTAssertTrue(state.auth.isLoading)

        state = appReducer(state: state, action: .loginSuccess(token: "abc123"))
        XCTAssertTrue(state.auth.isAuthenticated)
        XCTAssertEqual(state.auth.accessToken, "abc123")
        XCTAssertFalse(state.auth.isLoading)

        let user = GitHubUser(
            id: 1, login: "dev", avatarUrl: "", htmlUrl: "",
            name: "Dev", company: nil, blog: nil, location: nil,
            email: nil, bio: nil, publicRepos: 5, publicGists: 0,
            followers: 10, following: 5, createdAt: nil
        )
        state = appReducer(state: state, action: .fetchUserSuccess(user: user))
        XCTAssertEqual(state.user.currentUser?.login, "dev")

        state = appReducer(state: state, action: .logout)
        XCTAssertFalse(state.auth.isAuthenticated)
        XCTAssertNil(state.auth.accessToken)
        XCTAssertNil(state.user.currentUser)
    }
}
