//
//  NetAPIError.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation

public enum NetAPIError: Error {
    case invalidResponse(Data, URLResponse)
    case invalidData
    // 其他API特定错误...

    var localizedDescription: String {
        switch self {
        case let .invalidResponse(_, response):
            return "Invalid response from server: \(response)"
        case .invalidData:
            return "Invalid data received"
        }
    }
}
