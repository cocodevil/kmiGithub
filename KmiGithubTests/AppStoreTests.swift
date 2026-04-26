//
//  AppStoreTests.swift
//  KmiGithubTests
//
//  Created by Renzhong Xu on 2026/4/26.
//

import XCTest
@testable import KmiGithub

final class AppStoreTests: XCTestCase {

    func testStoreDispatchUpdatesState() {
        let store = AppStore(middlewares: [])

        let expectation = expectation(description: "State updated")

        store.dispatch(.loginStarted)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(store.state.auth.isLoading)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testStoreLoginSuccessFlow() {
        let store = AppStore(middlewares: [])

        let expectation = expectation(description: "Login completed")

        store.dispatch(.loginSuccess(token: "test_token"))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(store.state.auth.isAuthenticated)
            XCTAssertEqual(store.state.auth.accessToken, "test_token")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testStoreEnterGuestMode() {
        let store = AppStore(middlewares: [])

        let expectation = expectation(description: "Guest mode")

        store.dispatch(.enterGuest)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(store.state.auth.isGuest)
            XCTAssertFalse(store.state.auth.isAuthenticated)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testStoreLogoutClearsAll() {
        let store = AppStore(middlewares: [])

        let expectation = expectation(description: "Logout completed")

        store.dispatch(.loginSuccess(token: "token"))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            store.dispatch(.logout)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertFalse(store.state.auth.isAuthenticated)
                XCTAssertNil(store.state.auth.accessToken)
                XCTAssertNil(store.state.user.currentUser)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
