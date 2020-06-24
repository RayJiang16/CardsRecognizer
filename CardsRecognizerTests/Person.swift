//
//  Person.swift
//  CardsRecognizerTests
//
//  Created by 蒋惠 on 2020/6/24.
//

import Foundation
import SwiftyJSON
import CardsRecognizer

class Persion {
    /// 姓名
    let name: String
    /// 性别
    let sex: String
    /// 名族
    let nationality: String
    /// 出生日期
    let birth: String
    /// 住址
    let address: String
    /// 身份证号码
    let num: String
    /// 签发机关
    let issue: String
    /// 有效期开始日期
    let startDate: String
    /// 有效期结束日期
    let endDate: String
    /// 国徽面图片URL
    let frontUrl: String
    /// 人像面图片URL
    let backUrl: String
    
    var frontImage: UIImage? = nil
    var backImage: UIImage? = nil
    
    init(sex: String,
         num: String,
         name: String,
         birth: String,
         issue: String,
         address: String,
         endDate: String,
         backUrl: String,
         frontUrl: String,
         startDate: String,
         backImage: UIImage?,
         frontImage: UIImage?,
         nationality: String) {
        self.sex = sex
        self.num = num
        self.name = name
        self.birth = birth
        self.issue = issue
        self.address = address
        self.endDate = endDate
        self.backUrl = backUrl
        self.frontUrl = frontUrl
        self.startDate = startDate
        self.backImage = backImage
        self.frontImage = frontImage
        self.nationality = nationality
    }
}

// MARK: - Check data
extension Persion {
    
    @discardableResult
    func check(data: IDCard.Front) -> Bool {
        var errorCount = 0
        if issue != data.issue {
            errorCount += 1
            print("签发机关错误 原始数据:\(issue) 识别数据:\(data.issue)")
        }
        if startDate != data.startDate {
            errorCount += 1
            print("有效期开始日期错误 原始数据:\(startDate) 识别数据:\(data.startDate)")
        }
        if endDate != data.endDate {
            errorCount += 1
            print("有效期结束日期错误 原始数据:\(endDate) 识别数据:\(data.endDate)")
        }
        if errorCount == 0 {
            print("[\(name)]国徽面识别正确")
        } else if errorCount > 0 {
            print("[\(name)]国徽面识别一共错误\(errorCount)个")
            print("[\(name)]国徽面图片:\(frontUrl)")
        }
        return errorCount == 0
    }
    
    @discardableResult
    func check(data: IDCard.Back) -> Bool {
        var errorCount = 0
        if name != data.name {
            errorCount += 1
            print("姓名错误 原始数据:\(name) 识别数据:\(data.name)")
        }
        if sex != data.sex.rawValue {
            errorCount += 1
            print("性别错误 原始数据:\(sex) 识别数据:\(data.sex.rawValue)")
        }
        if nationality != data.nationality {
            errorCount += 1
            print("民族错误 原始数据:\(nationality) 识别数据:\(data.nationality)")
        }
        if birth != data.birth {
            errorCount += 1
            print("出生错误 原始数据:\(birth) 识别数据:\(data.birth)")
        }
        if address != data.address {
            errorCount += 1
            print("住址错误 原始数据:\(address) 识别数据:\(data.address)")
        }
        if num != data.num {
            errorCount += 1
            print("身份证错误 原始数据:\(num) 识别数据:\(data.num)")
        }
        if errorCount == 0 {
            print("[\(name)]人像面识别正确")
        } else if errorCount > 0 {
            print("[\(name)]人像面识别一共错误\(errorCount)个")
            print("[\(name)]人像面图片:\(backUrl)")
        }
        return errorCount == 0
    }
}

// MARK: - JSON
extension Persion {

    convenience init?(json: JSON) {
        guard
            let frontUrl = json["front_url"].string,
            let backUrl = json["back_url"].string
            else { return nil }
        var sex = json["sex"].stringValue
        let num = json["num"].stringValue
        let name = json["name"].stringValue
        var birth = json["birth"].stringValue
        let issue = json["issue"].stringValue
        let address = json["address"].stringValue
        var endDate = json["end_date"].stringValue
        var startDate = json["start_date"].stringValue
        let nationality = json["nationality"].stringValue
        
        // Format data if needed
        func formatData(dateStr: String, from fromFormat: String, to toFormat: String) -> String {
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = fromFormat
            guard let date = dateFormat.date(from: dateStr) else { return "" }
            dateFormat.dateFormat = toFormat
            return dateFormat.string(from: date)
        }
        
//        if num.count == 18 {
//            sex = Int((num as NSString).substring(with: NSRange(location: 16, length: 1)))! % 2 == 0 ? "女" : "男"
//            birth = (num as NSString).substring(with: NSRange(location: 6, length: 8))
//        }
//        birth = formatData(dateStr: birth, from: "yyyyMMdd", to: "yyyy-MM-dd")
//        startDate = formatData(dateStr: startDate, from: "yyyyMMdd", to: "yyyy-MM-dd")
//        if endDate != "长期" {
//            endDate = formatData(dateStr: endDate, from: "yyyyMMdd", to: "yyyy-MM-dd")
//        }
        
        self.init(sex: sex,
                  num: num,
                  name: name,
                  birth: birth,
                  issue: issue,
                  address: address,
                  endDate: endDate,
                  backUrl: backUrl,
                  frontUrl: frontUrl,
                  startDate: startDate,
                  backImage: nil,
                  frontImage: nil,
                  nationality: nationality)
    }
}
