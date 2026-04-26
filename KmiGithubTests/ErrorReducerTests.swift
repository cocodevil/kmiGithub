//
//  ErrorReducerTests.swift
//  KmiGithubTests
//
//  Created by Renzhong Xu on 2026/4/26.
//

import XCTest
@testable import KmiGithub

final class ErrorReducerTests: XCTestCase {

    func testShowErrorSetsError() {
        let state = ErrorState()
        let error = AppError.networkError("网络错误")
        let newState = errorReducer(state: state, action: .showError(error))

        XCTAssertTrue(newState.showError)
        XCTAssertEqual(newState.currentError, error)
    }

    func testDismissErrorClearsState() {
        var state = ErrorState()
        state.showError = true
        state.currentError = .networkError("error")
        let newState = errorReducer(state: state, action: .dismissError)

        XCTAssertFalse(newState.showError)
        XCTAssertNil(newState.currentError)
    }

    func testLoginFailedTriggersError() {
        let state = ErrorState()
        let error = AppError.authError("Auth failed")
        let newState = errorReducer(state: state, action: .loginFailed(error: error))

        XCTAssertTrue(newState.showError)
        XCTAssertEqual(newState.currentError, error)
    }

    func testFetchUserFailedTriggersError() {
        let state = ErrorState()
        let error = AppError.serverError("Server error")
        let newState = errorReducer(state: state, action: .fetchUserFailed(error: error))

        XCTAssertTrue(newState.showError)
        XCTAssertEqual(newState.currentError, error)
    }
}
