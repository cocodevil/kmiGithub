//
//  OCModel.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation
import ObjectiveC
//MARK: - 注意事项
//旧模型需要继承 OCModel 对象, 遵循 OCModelInitWithDic 协议
//init(dictionary:[String : Any]) 会提示添加 required
//不要重写 setValue(_ value: Any?, forUndefinedKey key: String) 方法，会报错

//旧OC模型协议
public protocol OCModelInitWithDic {
    init(dictionary:[String : Any])
}

open class OCModel: NSObject {
    public override func setValue(_ value: Any?, forUndefinedKey key: String) {
        // 1. 获取当前类的所有属性
        var count: UInt32 = 0
        guard let properties = class_copyPropertyList(type(of: self), &count) else {
            // 如果无法获取属性列表，则调用父类实现
            super.setValue(value, forUndefinedKey: key)
            return
        }
        defer {
            free(properties) // 释放 C 数组内存
        }

        // 2. 遍历属性，进行不区分大小写的比较
        for i in 0..<Int(count) {
            let property = properties[i]
            let propertyName_C = property_getName(property)
            let propertyName = String(cString: propertyName_C)
            // 3. 如果找到不区分大小写的匹配项
            if key.caseInsensitiveCompare(propertyName) == .orderedSame {
                // 4. 使用找到的、大小写正确的属性名来设置值
                // 注意：这里调用的是 self.setValue(_:forKey:) 而不是 super
                // 因为我们找到了正确的 key，要触发正常的 KVC 设置流程
                self.setValue(value, forKey: propertyName)
                return // 找到并处理完成，退出函数
            }
            
        }

        // 5. 如果遍历完所有属性都没有找到不区分大小写的匹配项
        //print("⚠️ Warning: Key '\(key)' not found (case-insensitive) in class \(type(of: self)).")
        // 调用父类的实现，这通常会导致 NSUndefinedKeyException 异常
        // 你也可以选择在这里静默处理，例如打印日志但不崩溃
        // super.setValue(value, forUndefinedKey: key) // 默认会崩溃
        // 或者不调用 super，选择忽略这个未定义的 key
        //print(" -> Ignoring undefined key '\(key)'.")
    }

    // 如果不希望未定义 key 崩溃，还需要重写这个
    open override func value(forUndefinedKey key: String) -> Any? {
        print("⚠️ Warning: Attempted to access undefined key '\(key)'")
        return nil // 返回 nil 而不是崩溃
    }
}
