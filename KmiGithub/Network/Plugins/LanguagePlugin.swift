//
//  LanguagePlugin.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import Moya

public class LanguagePlugin: PluginType {
    
    public enum LanguageHeader {
        case acceptLanguage
        case custom(String)
        
        var fieldName: String {
            switch self {
            case .acceptLanguage: return "Accept-Language"
            case .custom(let name): return name
            }
        }
    }
    
    private let languageProvider: () -> String
    private let headerType: LanguageHeader
    
    /// 初始化方法
    /// - Parameters:
    ///   - headerType: 语言头类型，默认是标准的 Accept-Language
    ///   - languageProvider: 返回当前语言代码的闭包
    public init(headerType: LanguageHeader = .acceptLanguage,
                languageProvider: @escaping () -> String = {
        // 默认实现
        if let language = Locale.current.languageCode {
        let region = Locale.current.regionCode ?? ""
        return "\(language)-\(region)"
    }
        return "en-US"
    }) {
        self.headerType = headerType
        self.languageProvider = languageProvider
    }
    
    /// Called to modify a request before sending.
    public func prepare(_ request: URLRequest, target: any TargetType) -> URLRequest {
        var request = request
        // 获取当前语言
        let languageCode = languageProvider()
        
        // 添加或替换语言头
        if request.value(forHTTPHeaderField: headerType.fieldName) != nil {
            request.setValue(languageCode, forHTTPHeaderField: headerType.fieldName)
        } else {
            request.addValue(languageCode, forHTTPHeaderField: headerType.fieldName)
        }
        return request
    }
    
    
}

