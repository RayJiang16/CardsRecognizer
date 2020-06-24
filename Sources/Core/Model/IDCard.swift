//
//  IDCard.swift
//  CardsRecognizer
//
//  Created by 蒋惠 on 2020/6/24.
//

import Foundation

/// 中华人民共和国居民身份证模型
public enum IDCard {
    /// 未知
    case unknown
    /// 身份证正面（国徽面）
    case front(Front)
    /// 身份证反面（人像面）
    case back(Back)
    
    /// 身份证面向
    public var side: Side {
        switch self {
        case .unknown:
            return .unknown
        case .front:
            return .front
        case .back:
            return .back
        }
    }
}

// MARK: - Front
extension IDCard {
    
    /// 身份证正面（国徽面）模型
    public struct Front {
        /// 签发机关
        let issue: String
        /// 有效期开始日期 yyyy-MM-dd
        let startDate: String
        /// 有效期结束日期 yyyy-MM-dd/长期
        let endDate: String
    }
}

// MARK: - Back
extension IDCard {
    
    /// 身份证反面（人像面）
    public struct Back {
        /// 姓名
        let name: String
        /// 性别
        let sex: Sex
        /// 名族
        let nationality: String
        /// 出生日期 yyyy-MM-dd
        let birth: String
        /// 住址
        let address: String
        /// 身份证号码
        let num: String
    }
}

// MARK: - Enum
extension IDCard {
    
    /// 身份证面向
    public enum Side {
        /// 未知
        case unknown
        /// 身份证正面（国徽面）
        case front
        /// 身份证反面（人像面）
        case back
    }
}

extension IDCard.Back {
    
    /// 性别
    public enum Sex: String {
        /// 未知
        case unknown = "未知"
        /// 男
        case man = "男"
        /// 女
        case woman = "女"
        
        init(string: String) {
            switch string {
            case "男":
                self = .man
            case "女":
                self = .woman
            default:
                self = .unknown
            }
        }
    }
}

// MARK: - Create
extension IDCard {
    
    static func createIDCard(by strings: [String]) -> IDCard {
        let strings = strings.map{ $0.replacingOccurrences(of: " ", with: "") }
        print(strings)
        switch side(of: strings) {
        case .front:
            return .front(Front(by: strings))
        case .back:
            return .back(Back(by: strings))
        case .unknown:
            return .unknown
        }
    }
    
    static func side(of strings: [String]) -> Side {
        for string in strings {
            if string.contains("中华人民共和国") || string.contains("身份证") {
                return .front
            } else if string.contains("公民") || string.contains("身份") || string.contains("号码") {
                return .back
            }
        }
        return .unknown
    }
}

extension IDCard.Front {
    
    // ["中华人民共和国", "居民身份证", "签发机关杭州市公安局", "有效期限", "2010.01.01-2020.01.01"]
    init(by strings: [String]) {
        var issue = ""
        var startDate = ""
        var endDate = ""
        for string in strings {
            if let range = string.range(of: "机关") {
                issue = String(string[range.upperBound..<string.endIndex])
            } else if string.contains("20") && string.contains("-") {
                let list = string.split(separator: "-")
                if list.count == 2 {
                    startDate = list.first!.replacingOccurrences(of: ".", with: "-")
                    endDate = list.last!.replacingOccurrences(of: ".", with: "-")
                }
            }
        }
        self.init(issue: issue, startDate: startDate, endDate: endDate)
    }
}

extension IDCard.Back {
    
    // ["姓名张三", "性别男民族汉", "出生2000年1月1日","住址浙江省杭州市", "001号", "公民身份号码3100000200001010202"]
    init(by strings: [String]) {
        var name = ""
        var sex = Sex.unknown
        var nationality = ""
        var birth = ""
        var address = ""
        var num = ""
        var index = 0
        for string in strings {
            if index == 0 && (string.contains("姓名") || string.contains("姓") || string.contains("名")) {
                index = 1
                if let range = string.range(of: "名") {
                    name = String(string[range.upperBound..<string.endIndex])
                }
            } else if index == 1 && (string.contains("性别") || string.contains("性") || string.contains("别")) {
                index = 2
                let nationalityString: String
                if let range = string.range(of: "别") {
                    let sexEndIndex = string.index(range.upperBound, offsetBy: 1)
                    let sexStr = String(string[range.upperBound..<sexEndIndex])
                    sex = Sex(string: sexStr)
                    nationalityString = String(string[sexEndIndex..<string.endIndex])
                } else {
                    nationalityString = string
                }
                if let nationalityRange = nationalityString.range(of: "族") {
                    nationality = String(nationalityString[nationalityRange.upperBound..<nationalityString.endIndex])
                }
            } else if index == 2 && (string.contains("出生") || string.contains("出") || string.contains("生")) {
                index = 3
                var birthList: [String] = []
                var str = ""
                for c in string { // 48-57
                    let ascii = c.asciiValue ?? 0
                    let isNum = 48 <= ascii && ascii <= 57
                    if isNum {
                        str += String(c)
                    } else if !str.isEmpty {
                        birthList.append(str)
                        str = ""
                    }
                }
                birth = birthList.map{ $0.count == 1 ? "0\($0)" : $0 }.joined(separator: "-")
            } else if index == 3 && (string.contains("住址") || string.contains("住") || string.contains("址")) {
                index = 4
                if let range = string.range(of: "址") {
                    address = String(string[range.upperBound..<string.endIndex])
                }
            } else if index == 4 && (string.contains("公民") || string.contains("身份")) {
                index = 5
                for c in string { // 48-57
                    let ascii = c.asciiValue ?? 0
                    let isNum = 48 <= ascii && ascii <= 57
                    if isNum {
                        num += String(c)
                    }
                }
                if num.count == 17 {
                    num += "X"
                }
            } else if index == 4 { // 住址补充
                address += string
            }
        }
        self.init(name: name, sex: sex, nationality: nationality, birth: birth, address: address, num: num)
    }
}