//
//  NetworkResponse.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation


public struct NetworkResponse<T:Decodable>: Decodable {
    let msg: String?
    let code: Int?
    var data: T? //可能是单个对象或者数组
    var traceId: String?
}

public struct NetworkBaseResponse: Decodable {
    let msg: String?
    let code: Int?
    var data: Data //可能是单个对象或者数组
    var traceId: String?
}

public struct NetworkSResponse: Decodable {
    let msg: String?
    let code: Int?
    var traceId: String?
}

//TODO: - need check TopTraderEAPIsError(replace)
public struct NetworkTopTraderEAPIsError: Error, Codable {
    public var api: String?
    public var actCode: String?
    public var errNo: String?
    public var errDesc: String?
    public var errDescEN: String?
    public var errDescTW: String?
    public var errDescCN: String?
    
    public init(api: String? = nil, actCode: String? = nil, errNo: String? = nil, errDesc: String? = nil, errDescEN: String? = nil, errDescTW: String? = nil, errDescCN: String? = nil) {
        self.api = api
        self.actCode = actCode
        self.errNo = errNo
        self.errDesc = errDesc
        self.errDescEN = errDescEN
        self.errDescTW = errDescTW
        self.errDescCN = errDescCN
    }
}
