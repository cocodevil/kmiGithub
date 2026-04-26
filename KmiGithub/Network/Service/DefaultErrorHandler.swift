//
//  DefaultErrorHandler.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import Moya

/// 错误处理协议
public protocol ErrorHandler {
    func handleMoyaError(_ error: MoyaError) -> NetworkError
    func handleDecodingError(_ error: DecodingError) -> NetworkError
    func handleUnknownError(_ error: Error) -> NetworkError
}

public enum NetworkError: Error, LocalizedError {
    case networkError(URLError)
    case serverError(message: String, code: Int, traceId: String)
    case serverErrorReturn(error: NetworkTopTraderEAPIsError)
    case decodingError(DecodingError)
    case invalidURL(url: String)
    case unknownError(Error)
    case apiError(NetAPIError)
    case noData(traceId: String)
    case invalidStatusCode(Int)
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let urlError):
            return urlError.localizedDescription
        case .serverError(let message, let code, let traceId):
            return "Server Error \(code): \(message): \(traceId)"
        case .serverErrorReturn(let error):
            return "API error: \(error.localizedDescription)"
        case .decodingError(let decodingError):
            return "Decoding Error: \(decodingError.localizedDescription)"
        case .invalidURL(url: let url):
            return "[🔥] Bad response from URL: \(url)"
        case .unknownError(let error):
            return "[⚠️]Unknown Error: \(error.localizedDescription)"
        case .apiError(let error): return "API error: \(error.localizedDescription)"
        case .noData(traceId: let traceId):
            return "[🔥] No Data from traceId: \(traceId)"
        case .invalidStatusCode(let code):
            return "[🔥] invalidStatusCode: \(code)"
        }
    }
}

public struct DefaultErrorHandler: ErrorHandler {
    
    public init() {}
    
    public func handleMoyaError(_ error: MoyaError) -> NetworkError {
        switch error {
        case .statusCode(let response):
            return .serverError(
                message: HTTPURLResponse.localizedString(forStatusCode: response.statusCode),
                code: response.statusCode,
                traceId: ""
            )
        case .underlying(let underlyingError, _):
            if let urlError = underlyingError as? URLError {
                return .networkError(urlError)
            }
            return .unknownError(underlyingError)
        default:
            return .unknownError(error)
        }
    }
    
    public func handleDecodingError(_ error: DecodingError) -> NetworkError {
        return .decodingError(error)
    }
    
    public func handleUnknownError(_ error: Error) -> NetworkError {
        return .unknownError(error)
    }
}


