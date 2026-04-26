//
//  KeychainService.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import Security

enum KeychainService {

    static func save(token: String) {
        guard let data = token.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: AppConstants.keychainTokenKey,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "KmiGithub"
        ]

        SecItemDelete(query as CFDictionary)

        var addQuery = query
        addQuery[kSecValueData as String] = data

        SecItemAdd(addQuery as CFDictionary, nil)
    }

    static func loadToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: AppConstants.keychainTokenKey,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "KmiGithub",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    static func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: AppConstants.keychainTokenKey,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "KmiGithub"
        ]

        SecItemDelete(query as CFDictionary)
    }

    static var hasToken: Bool {
        loadToken() != nil
    }
}
