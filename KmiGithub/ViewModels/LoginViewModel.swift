//
//  LoginViewModel.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    @Published var isLoading = false

    weak var store: AppStore?
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()

    var canUseBiometric: Bool {
        BiometricService.isAvailable && KeychainService.hasToken
    }

    var biometricName: String {
        BiometricService.biometricName
    }

    func loginWithGitHub() {
        guard let store else { return }
        isLoading = true
        store.dispatch(.loginStarted)

        authService.startOAuthFlow()
            .flatMap { [weak self] code -> AnyPublisher<String, AppError> in
                guard let self else {
                    return Fail(error: AppError.authError("服务不可用")).eraseToAnyPublisher()
                }
                return self.authService.exchangeCodeForToken(code: code)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.store?.dispatch(.loginFailed(error: error))
                    }
                },
                receiveValue: { [weak self] token in
                    self?.store?.dispatch(.loginSuccess(token: token))
                }
            )
            .store(in: &cancellables)
    }

    func loginWithBiometric() {
        isLoading = true

        BiometricService.authenticate()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.store?.dispatch(.loginFailed(error: error))
                    }
                },
                receiveValue: { [weak self] _ in
                    if let token = KeychainService.loadToken() {
                        self?.store?.dispatch(.loginSuccess(token: token))
                    }
                }
            )
            .store(in: &cancellables)
    }

    func skipLogin() {
        store?.dispatch(.enterGuest)
    }
}
