//
//  BiometricService.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import LocalAuthentication
import Combine

enum BiometricType {
    case none
    case faceID
    case touchID
}

final class BiometricService {

    static var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }

    static var isAvailable: Bool {
        biometricType != .none
    }

    static var biometricName: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .none: return ""
        }
    }

    static func authenticate() -> AnyPublisher<Bool, AppError> {
        Future<Bool, AppError> { promise in
            let context = LAContext()
            var error: NSError?

            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                promise(.failure(.authError("生物识别不可用")))
                return
            }

            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "使用 \(biometricName) 登录您的 GitHub 账户"
            ) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        promise(.success(true))
                    } else {
                        let message = authError?.localizedDescription ?? "认证失败"
                        promise(.failure(.authError(message)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
