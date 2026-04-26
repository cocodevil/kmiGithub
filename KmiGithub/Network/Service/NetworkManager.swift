//
//  NetworkManager.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import Combine
import Moya
import CombineMoya

public let isCanLogStr: Bool = true
// MARK: - Combine网络请求

/// 网络服务协议
public protocol NetworkServiceProtocol {
    associatedtype Target: TargetType
    associatedtype CacheTarget = TargetType & Cacheable
    
    // 返回Data数据 需自己解析数据
    func requestReturnData(_ target: Target) -> AnyPublisher<Data, Error>
    // 返回后台接口返回的整个model
    func requestReturnModel<T: Decodable>(_ target: Target, responseType: T.Type) -> AnyPublisher<T, NetworkError>
    // 返回data里面包装的模型
    func requestToTypeModel<T: Decodable>(_ target: Target, responseType: T.Type) -> AnyPublisher<T, NetworkError>
    // 带重试请求
    func requestWithRetry<T: Decodable>(_ target: Target, responseType: T.Type, retries: Int, delay: TimeInterval) -> AnyPublisher<T, NetworkError>
    // 带缓存请求
    func requestWithCache<T: Codable>(_ target: CacheTarget, responseType: T.Type) -> AnyPublisher<T, NetworkError>
}

public class NetworkManager<Target: TargetType>: NetworkServiceProtocol {
    
    public var provider: MoyaProvider<Target>
    public var cacheProvider: CacheProvider?
    public var errorHandler: ErrorHandler
    public var jsonDecoder: JSONDecoder
    public var scheduler: DispatchQueue
    //请求后台接口成功的code码
    public var SuccessCode: Int = 0
    //请求后台接口失效的code码
    public var TokenExpiredCode: Int = -201
    //默认失败处理的code码
    public var FailureCode: Int = -999
    
    public init(provider: MoyaProvider<Target> = MoyaProvider<Target>(plugins: [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    ]),
                cacheProvider: CacheProvider? = nil,
                errorHandler: ErrorHandler = DefaultErrorHandler(),
                jsonDecoder: JSONDecoder = JSONDecoder(),
                scheduler: DispatchQueue = .global(qos: .utility)
    ){
        self.provider = provider
        self.cacheProvider = cacheProvider
        self.errorHandler = errorHandler
        self.jsonDecoder = jsonDecoder
        self.scheduler = scheduler
        // 配置日期解码策略
        self.jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - 核心请求方法
    /// 基础请求方法 返回Data
    public func requestReturnData(_ target: Target) -> AnyPublisher<Data, Error> {
        provider.requestPublisher(target)
            .tryMap({ response in
                // 检查返回的 code 是否表示成功
                guard (200...299).contains(response.statusCode) else {
                    throw NetworkError.invalidURL(url: response.response?.url?.absoluteString ?? "")
                }
                return response.data
            })
            .mapError{ [weak self] error in
                self?.handleError(error) ?? .unknownError(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 请求并解析为指定模型，包含接口底层code msg traceId
    /// 请求并解析为指定模型，包含接口底层code msg traceId
    public func requestReturnModel<T: Decodable>(_ target: Target, responseType: T.Type) -> AnyPublisher<T, NetworkError> {
        return provider.requestPublisher(target)
            .tryMap{ response in //Response
                guard (200...299).contains(response.statusCode) else {
                    throw NetworkError.invalidURL(url: (response.response?.url?.absoluteString ?? ""))
                }
                if isCanLogStr {
                    let str = String(data: response.data, encoding: .utf8)
                    print(str ?? "Encode error")
                }
                return response.data
            }
            .decode(type: T.self, decoder: jsonDecoder)
            .mapError { [weak self] error in
                self?.handleError(error) ?? .unknownError(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 请求并解析为指定模型 返回data里面的模型
    ///请求并解析为指定模型 返回data里面的模型
    public func requestToTypeModel<T>(_ target: Target, responseType: T.Type) -> AnyPublisher<T, NetworkError> where T : Decodable {
        provider.requestPublisher(target)
            .tryMap { responseData -> Data in // Moya.Response
                // 1. 首先检查HTTP状态码
                guard (200...299).contains(responseData.statusCode) else {
                    print("❌ Invalid status code")
                    throw NetworkError.invalidStatusCode(responseData.statusCode)
                }
                if isCanLogStr {
                    let str = String(data: responseData.data, encoding: .utf8)
                    print(str ?? "Encode error")
                }
                return responseData.data
            }
            .tryMap { [self] data -> T in
                // 2. 尝试解码为NetworkResponse<T>
                do {
                    // 提前检查 Data 的 JSON 对象，查看内部是否 数组 且包含 ErrNo 字段，如果有则抛出 第一个 字典解码对象
                    let errorFormat = data.checkJsonDataContains("errNo")
                    guard errorFormat != .arraySuccess,errorFormat != .dictSuccess else {
                        if errorFormat == .arraySuccess {
                            let errorResponse = try self.jsonDecoder.decode(NetworkResponse<[NetworkTopTraderEAPIsError]>.self, from: data)
                            guard let firstError = errorResponse.data?.first else {
                                throw NetworkError.noData(traceId: "❌ No data or empty error array in response")
                            }
                            throw NetworkError.serverErrorReturn(error: firstError)
                            
                        }else{
                            let errorResponse = try self.jsonDecoder.decode(NetworkResponse<NetworkTopTraderEAPIsError>.self, from: data)
                            guard let singleError = errorResponse.data else {
                                throw NetworkError.noData(traceId: "❌ No data field for single error in response")
                            }
                            throw NetworkError.serverErrorReturn(error: singleError)
                        }
                       
                    }
                    
                    let networkResponse = try self.jsonDecoder.decode(NetworkResponse<T>.self, from: data)
                    // 3. 检查业务状态码 可在这里处理状态码 如未登录的逻辑
                    if networkResponse.code == TokenExpiredCode {
                        print("Token已失效，请重新登录")
                    }
                    guard networkResponse.code == SuccessCode else {
                                                
                        throw NetworkError.serverError(
                            message: networkResponse.msg ?? "Unknown error",
                            code: networkResponse.code ?? FailureCode,
                            traceId: networkResponse.traceId ?? ""
                        )
                    }
                    // 4. 检查数据是否存在
                    guard let responseData = networkResponse.data else {
                        throw NetworkError.noData(traceId: networkResponse.traceId ?? "❌ No data field in response")
                    }
                    return responseData
                } catch let decodingError as DecodingError {
                    print("‼️ \(T.self) Decoding failed: \(decodingError)")
                    throw NetworkError.decodingError(decodingError)
                }
                catch {
                    print("‼️ Decoding failed: \(error)")
                    throw error
                }
            }
            .mapError { [weak self] error in
                self?.handleError(error) ?? .unknownError(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 带缓存请求
    /// 带缓存请求
    public func requestWithCache<T>(_ target: CacheTarget, responseType: T.Type) -> AnyPublisher<T, NetworkError> where T : Codable {
        // 安全转换 Target
        guard let actualTarget = target as? Target else {
            return Fail(error: NetworkError.invalidURL(url: target.baseURL.absoluteString))
                .eraseToAnyPublisher()
        }
        guard target.shouldCache else {
            return request(actualTarget,responseTtype: T.self)
        }
        // 尝试从缓存读取
        if let cached: T = cacheProvider?.get(target.cacheKey) {
            return Just(cached)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        
        // 发起网络请求
        return request(actualTarget,responseTtype: T.self)
            .handleEvents(receiveOutput: { [weak self] value in
                guard target.cacheExpiry > 0 else { return }
                self?.cacheProvider?.set(value, forKey: target.cacheKey, expiry: target.cacheExpiry)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: - 带重试请求
    /// 带重试请求
    public func requestWithRetry<T: Decodable>(
        _ target: Target,
        responseType: T.Type,
        retries: Int = 2,
        delay: TimeInterval = 1
    ) -> AnyPublisher<T, NetworkError> {
        return request(target,responseTtype: T.self)
            .retry(retries)
            .delay(for: .seconds(delay), scheduler: scheduler)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 私有方法
    
    private func request<T: Decodable>(_ target: Target, responseTtype: T.Type) -> AnyPublisher<T, NetworkError> {
        return requestReturnModel(target,responseType: T.self)
    }
    
    private func handleResponse<T: Decodable>(_ response: Response, decoder: JSONDecoder, responseType: T.Type) throws -> Data {
        guard (200...299).contains(response.statusCode) else {
            let errorResponse = try? decoder.decode(NetworkResponse<T>.self, from: response.data)
            throw NetworkError.serverError(
                message: errorResponse?.msg ?? "Unknown error",
                code: response.statusCode,
                traceId: ""
            )
        }
        return response.data
    }
    
    func handleError(_ error: Error) -> NetworkError {
        if let moyaError = error as? MoyaError {
            return errorHandler.handleMoyaError(moyaError)
        } else if let decodingError = error as? DecodingError {
            return errorHandler.handleDecodingError(decodingError)
        } else if let networkError = error as? NetworkError {
            return networkError
        }
        return errorHandler.handleUnknownError(error)
    }
    
    private func cacheValue<T: Codable>(_ value: T, for target: CacheTarget) {
        guard target.shouldCache, target.cacheExpiry > 0 else { return }
        cacheProvider?.set(value, forKey: target.cacheKey, expiry: target.cacheExpiry)
    }
    
    static func handleCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}

