//
//  TokenPlugin.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

///由于默认的 AccessTokenPlugin 会增加相应的头在token前面 且外部没法改 所以自定义此token

import Foundation
import Moya


// MARK: - AccessTokenPlugin

/**
 A plugin for adding basic or bearer-type authorization headers to requests. Example:

 ```
 Authorization: Basic <token>
 Authorization: Bearer <token>
 Authorization: <Сustom> <token>
 ```

 */
public struct CustomTokenPlugin: PluginType {

    public typealias TokenClosure = (TargetType) -> String

    /// A closure returning the access token to be applied in the header.
    public let tokenClosure: TokenClosure

    /**
     Initialize a new `AccessTokenPlugin`.

     - parameters:
     - tokenClosure: A closure returning the token to be applied in the pattern `Authorization: <AuthorizationType> <token>`
     */
    public init(tokenClosure: @escaping TokenClosure) {
        self.tokenClosure = tokenClosure
    }

    /**
     Prepare a request by adding an authorization header if necessary.

     - parameters:
     - request: The request to modify.
     - target: The target of the request.
     - returns: The modified `URLRequest`.
     */
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {

        guard let authorizable = target as? AccessTokenAuthorizable,
              let _ = authorizable.authorizationType
            else { return request }

        var request = request
        let realTarget = (target as? MultiTarget)?.target ?? target
        let authValue = tokenClosure(realTarget)
        request.addValue(authValue, forHTTPHeaderField: authorizable.authorizationType?.value ?? "Authorization")

        return request
    }
}

