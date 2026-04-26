//
//  AuthReducerTests.swift
//  KmiGithubTests
//
//  Created by Renzhong Xu on 2026/4/26.
//

import XCTest
@testable import KmiGithub

final class AuthReducerTests: XCTestCase {

    func testLoginStartedSetsLoading() {
        let state = AuthState()
        let newState = authReducer(state: state, action: .loginStarted)

        XCTAssertTrue(newState.isLoading)
        XCTAssertFalse(newState.isAuthenticated)
    }

    func testLoginSuccessSetsAuthenticated() {
        var state = AuthState()
        state.isLoading = true
        let newState = authReducer(state: state, action: .loginSuccess(token: "test_token"))

        XCTAssertTrue(newState.isAuthenticated)
        XCTAssertFalse(newState.isGuest)
        XCTAssertFalse(newState.isLoading)
        XCTAssertEqual(newState.accessToken, "test_token")
    }

    func testLoginFailedClearsLoading() {
        var state = AuthState()
        state.isLoading = true
        let error = AppError.authError("Failed")
        let newState = authReducer(state: state, action: .loginFailed(error: error))

        XCTAssertFalse(newState.isLoading)
        XCTAssertFalse(newState.isAuthenticated)
    }

    func testLogoutClearsState() {
        var state = AuthState()
        state.isAuthenticated = true
        state.accessToken = "token"
        let newState = authReducer(state: state, action: .logout)

        XCTAssertFalse(newState.isAuthenticated)
        XCTAssertFalse(newState.isGuest)
        XCTAssertNil(newState.accessToken)
    }

    func testEnterGuestSetsGuestMode() {
        let state = AuthState()
        let newState = authReducer(state: state, action: .enterGuest)

        XCTAssertTrue(newState.isGuest)
        XCTAssertFalse(newState.isAuthenticated)
        XCTAssertNil(newState.accessToken)
    }

    func testLoginSuccessExitsGuestMode() {
        var state = AuthState()
        state.isGuest = true
        let newState = authReducer(state: state, action: .loginSuccess(token: "token"))

        XCTAssertFalse(newState.isGuest)
        XCTAssertTrue(newState.isAuthenticated)
    }
}
