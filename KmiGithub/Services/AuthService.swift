//
//  AuthService.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import AuthenticationServices
import Combine

final class AuthService: NSObject, ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var authSession: ASWebAuthenticationSession?

    func startOAuthFlow() -> AnyPublisher<String, AppError> {
        Future<String, AppError> { [weak self] promise in
            guard let self else {
                promise(.failure(.authError("服务不可用")))
                return
            }

            let scope = "user,repo"
            let urlString = "\(AppConstants.githubAuthURL)?client_id=\(AppConstants.githubClientID)&redirect_uri=\(AppConstants.oauthCallbackURL)&scope=\(scope)"

            guard let url = URL(string: urlString) else {
                promise(.failure(.authError("无效的认证地址")))
                return
            }

            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: AppConstants.oauthCallbackScheme
            ) { [weak self] callbackURL, error in
                self?.authSession = nil

                if let error {
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        promise(.failure(.userCancelled))
                        return
                    }
                    promise(.failure(.authError(error.localizedDescription)))
                    return
                }

                guard let callbackURL,
                      let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let code = components.queryItems?.first(where: { $0.name == "code" })?.value
                else {
                    promise(.failure(.authError("无法获取授权码")))
                    return
                }

                promise(.success(code))
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self.authSession = session
            session.start()
        }
        .eraseToAnyPublisher()
    }

    func exchangeCodeForToken(code: String) -> AnyPublisher<String, AppError> {
        GitHubService.shared.exchangeToken(code: code)
            .map(\.accessToken)
            .mapError { AppError.from($0) }
            .eraseToAnyPublisher()
    }
}

extension AuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first
        else {
            return ASPresentationAnchor()
        }
        return window
    }
}
