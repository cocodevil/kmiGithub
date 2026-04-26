//
//  JsonChecker.swift
//  KmiGithub
//
//  Created by Renzhong Xu on 2026/4/26.
//

import Foundation

enum JsonCheckResult {
    case arraySuccess // 是数组，元素是字典，且至少一个字典包含 传入的 key
    case dictSuccess // 是字典，包含 传入的 key
    case isNotAnArray // JSON 顶层不是数组
    case elementIsNotDictionary // 数组中包含非字典类型的元素
    case keyNotFound // 是字典数组，但没有任何字典包含 key
    case invalidJson // Data 不是有效的 JSON
    case arrayIsEmpty // 是数组，但数组为空，无法检查元素
}

extension Data {
    func checkJsonDataContains(_ key: String) -> JsonCheckResult {
        do {
            
            let response = try JSONSerialization.jsonObject(with: self, options: []) as? [String:Any]
            let jsonObject = response?["data"]
            // 1. 尝试将 Data 解析为 JSON 对象 (Any 类型)
            let jsonDict = jsonObject as? [String:Any]
            if jsonDict?[key] != nil {
                return .dictSuccess
            }
            
            // 2. 检查顶层对象是否是一个数组 (Swift 的 [Any] 类型)
            guard let jsonArray = jsonObject as? [Any] else {
                // 如果不是数组，直接返回
                // (注意：jsonObject as? [[String: Any]] 也可以直接判断是否为字典数组，
                // 但分开判断可以给出更精确的错误原因)
                return .isNotAnArray
            }

            // 2.1 (可选) 检查数组是否为空
            if jsonArray.isEmpty {
                return .arrayIsEmpty
            }

            // 3. 检查数组内的元素是否都是字典 ([String: Any])
            //    并同时检查是否有 errorCode 字段
            var foundKey = false
            for element in jsonArray {
                // 检查当前元素是否是字典
                guard let dictionaryElement = element as? [String: Any] else {
                    // 如果数组中有一个元素不是字典，则不满足条件
                    return .elementIsNotDictionary
                }

                // 检查这个字典是否包含 "errorCode" 键
                if dictionaryElement[key] != nil {
                    foundKey = true
                    // 如果只需要找到至少一个包含 errorCode 的即可，可以在这里提前退出循环
                     break // 取消注释这行可以提高效率，如果找到一个就够了
                }
            }

            // 4. 根据是否找到 errorCode 返回结果
            if foundKey {
                return .arraySuccess
            } else {
                // 遍历完了所有字典，都没找到 errorCode
                return .keyNotFound
            }

        } catch {
            // 如果 JSONSerialization.jsonObject 抛出错误，说明 Data 不是有效的 JSON
            print("JSON 解析失败: \(error.localizedDescription)")
            return .invalidJson
        }
    }
    
    
}


/*
// --- 示例用法 ---

// 示例 1: 成功的 JSON 数据
let jsonDataSuccess = """
[
    {"id": 1, "value": "abc"},
    {"id": 2, "errorCode": 404, "message": "Not Found"},
    {"id": 3, "value": "xyz"}
]
""".data(using: .utf8)!

let result1 = checkJsonDataStructure(data: jsonDataSuccess)
print("示例 1 结果: \(result1)") // 输出: 示例 1 结果: success

// 示例 2: 顶层不是数组
let jsonDataNotArray = """
{"errorCode": 500, "message": "Server Error"}
""".data(using: .utf8)!

let result2 = checkJsonDataStructure(data: jsonDataNotArray)
print("示例 2 结果: \(result2)") // 输出: 示例 2 结果: isNotAnArray

// 示例 3: 数组元素不全是字典
let jsonDataMixedElements = """
[
    {"id": 1},
    "I am a string, not a dictionary",
    {"id": 3, "errorCode": 0}
]
""".data(using: .utf8)!

let result3 = checkJsonDataStructure(data: jsonDataMixedElements)
print("示例 3 结果: \(result3)") // 输出: 示例 3 结果: elementIsNotDictionary

// 示例 4: 是字典数组，但没有 errorCode
let jsonDataNoErrorcode = """
[
    {"id": 1, "message": "OK"},
    {"id": 2, "status": "pending"}
]
""".data(using: .utf8)!

let result4 = checkJsonDataStructure(data: jsonDataNoErrorcode)
print("示例 4 结果: \(result4)") // 输出: 示例 4 结果: errorCodeNotFound

// 示例 5: 无效的 JSON
let jsonDataInvalid = "[{'id': 1]".data(using: .utf8)! // JSON 格式错误

let result5 = checkJsonDataStructure(data: jsonDataInvalid)
print("示例 5 结果: \(result5)") // 输出: 示例 5 结果: invalidJson (并打印解析错误信息)

// 示例 6: 空数组
let jsonDataEmptyArray = "[]".data(using: .utf8)!

let result6 = checkJsonDataStructure(data: jsonDataEmptyArray)
print("示例 6 结果: \(result6)") // 输出: 示例 6 结果: arrayIsEmpty
*/
