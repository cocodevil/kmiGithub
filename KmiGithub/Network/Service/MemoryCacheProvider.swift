//
//  MemoryCacheProvider.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation

///缓存协议
public protocol Cacheable {
    var cacheKey: String { get }
    var cacheExpiry: TimeInterval { get }
    var shouldCache: Bool { get }
}

public protocol CacheProvider {
    func get<T: Decodable>(_ key: String) -> T?
    func set<T: Encodable>(_ value: T, forKey key: String, expiry: TimeInterval)
    func remove(_ key: String)
}

public class MemoryCacheProvider: CacheProvider {
    private var cache = NSCache<NSString, AnyObject>()
    private var expiryDates = [String: Date]()
    
    public func get<T: Decodable>(_ key: String) -> T? {
        guard let expiryDate = expiryDates[key], expiryDate > Date() else {
            remove(key)
            return nil
        }
        
        return cache.object(forKey: key as NSString) as? T
    }
    
    public func set<T: Encodable>(_ value: T, forKey key: String, expiry: TimeInterval) {
        cache.setObject(value as AnyObject, forKey: key as NSString)
        expiryDates[key] = Date().addingTimeInterval(expiry)
    }
    
    public func remove(_ key: String) {
        cache.removeObject(forKey: key as NSString)
        expiryDates.removeValue(forKey: key)
    }
}

