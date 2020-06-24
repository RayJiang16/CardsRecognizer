//
//  Person.swift
//  CardsRecognizerTests
//
//  Created by 蒋惠 on 2020/6/24.
//

import Foundation
import SwiftyJSON

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

extension Persion {

    convenience init?(json: JSON) {
        guard
            let faceUrl = json["face_url"].string,
            let backUrl = json["back_url"].string
            else { return nil }
        let sex = json["sex"].stringValue
        let num = json["num"].stringValue
        let name = json["name"].stringValue
        let birth = json["birth"].stringValue
        let issue = json["issue"].stringValue
        let address = json["address"].stringValue
        let endDate = json["end_date"].stringValue
        let startDate = json["start_date"].stringValue
        let nationality = json["nationality"].stringValue
        self.init(sex: sex,
                  num: num,
                  name: name,
                  birth: birth,
                  issue: issue,
                  address: address,
                  endDate: endDate,
                  backUrl: faceUrl,
                  frontUrl: backUrl,
                  startDate: startDate,
                  backImage: nil,
                  frontImage: nil,
                  nationality: nationality)
    }
}
