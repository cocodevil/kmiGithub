//
//  NetworkManager+Extension.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import Combine
import Moya
import CombineMoya

extension NetworkManager {
    // MARK: - 请求并解析为指定*老*模型
    // ！返回数据需要自行重新确定类型！
    public func requestToOldTypeModel<T:OCModelInitWithDic>(_ target: Target, responseType: T.Type) -> AnyPublisher<Any, NetworkError>{
        provider.requestPublisher(target)
            .tryMap { responseData -> Data in // Moya.Response
                // 1. 首先检查HTTP状态码
                guard (200...299).contains(responseData.statusCode) else {
                    print("❌ Invalid status code")
                    throw NetworkError.invalidStatusCode(responseData.statusCode)
                }
                return responseData.data
            }
            .tryMap { [self] data -> Any? in
                // 2. 尝试解码为NetworkResponse<T>
                do {
                    let networkResponse = try self.jsonDecoder.decode(NetworkSResponse.self, from: data)
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
                    let responseData = try JSONSerialization.jsonObject(with: data) as? [String:Any]
                    
                    let responseJson = responseData?["data"]
                   
                    if let jsonDict = responseJson as? [String: Any] {
                        let model = responseType.init(dictionary: jsonDict)
                        return model
                    } else if let jsonArray = responseJson as? [[String: Any]] {
                        let models = jsonArray.compactMap { dict -> OCModelInitWithDic? in
                            return responseType.init(dictionary: dict)
                        }
                        return models
                    } else {
                        return nil
                    }
                } catch let decodingError as DecodingError {
                    //  如果解码NetworkResponse失败，尝试解析原始错误信息
                    if let errorResponse = try? self.jsonDecoder.decode(NetworkResponse<String>.self, from: data) {
                        throw NetworkError.serverError(
                            message: errorResponse.msg ?? "Unknown error",
                            code: errorResponse.code ?? FailureCode,
                            traceId: errorResponse.traceId ?? ""
                        )
                    }
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

    
    public func requestToJsonObj(_ target: Target) -> AnyPublisher<Any?, NetworkError> {
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
            .tryMap { [self] data in
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
                    
                    let networkResponse = try self.jsonDecoder.decode(NetworkSResponse.self, from: data)
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
                    let responseData = try JSONSerialization.jsonObject(with: data) as? [String:Any]
                    
                    let responseJson = responseData?["data"]
                    return responseJson
                } catch let decodingError as DecodingError {
                    print("‼️ Decoding failed: \(decodingError)")
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
}
