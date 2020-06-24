//
//  ViewController.swift
//  CardsRecognizerTests
//
//  Created by 蒋惠 on 2020/6/24.
//

import UIKit
import SwiftyJSON
import Kingfisher
import CardsRecognizer

class ViewController: UIViewController {

    var list: [Persion] = []
    var errorCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func loadData() {
        readDataJsonFile()
        if !list.isEmpty {
            DispatchQueue.global().async {
                self.startTest()
            }
        }
    }
    
    private func startTest() {
        print("开始测试 测试数量: \(list.count)")
        
        let semaphore = DispatchSemaphore(value: 1)
        for obj in list {
            semaphore.wait()
            downloadPhoto(obj: obj) { (success) in
                if !success {
                    semaphore.signal()
                    return
                }
                self.recognize(obj: obj) {
                    semaphore.signal()
                }
            }
        }
        semaphore.wait()
        print("识别结束，一共识别错误\(errorCount)个")
        semaphore.signal()
    }
    
    private func recognize(obj: Persion, completion: @escaping (() -> Void)) {
        print("开始识别: \(obj.name)")
        let group = DispatchGroup()
        for image in [obj.frontImage!, obj.backImage!] {
            group.enter()
            Recognizer.recognizeIDCard(source: image) { (result) in
                switch result {
                case .success(let cards):
                    for card in cards {
                        switch card {
                        case .front(let frontCard):
                            if !obj.check(data: frontCard) {
                                self.errorCount += 1
                            }
                        case .back(let backCard):
                            if !obj.check(data: backCard) {
                                self.errorCount += 1
                            }
                        case .unknown:
                            print("未知")
                        }
                    }
                case .failure(let error):
                    print(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("===============================")
            completion()
        }
    }
}

// MARK: - Helper
extension ViewController {
    
    private func readDataJsonFile() {
        guard let dataPath = Bundle.main.path(forResource: "Data", ofType: "json") else {
            print("Data.json 文件不存在，请按照 Example.json 文件的格式做好 json 数据，放入 Data.json 中")
            return
        }
        let jsonStr = (try? String(contentsOfFile: dataPath)) ?? ""
        if jsonStr.count < 5 {
            print("Data.json 文件内存为空，请按照 Example.json 文件的格式做好 json 数据，放入 Data.json 中")
            return
        }
        let json = JSON(parseJSON: jsonStr)
        list = json.arrayValue.compactMap { Persion(json: $0) }
        if list.isEmpty {
            print("Data.json 数据格式错误或数据缺失")
            return
        }
    }
    
    private func downloadPhoto(obj: Persion, completion: @escaping ((Bool) -> Void)) {
        guard let frontUrl = URL(string: obj.frontUrl) else {
            print("[\(obj.name)]身份证国徽面图片URL错误: \(obj.frontUrl)")
            return
        }
        guard let backUrl = URL(string: obj.backUrl) else {
            print("[\(obj.name)]身份证人像面图片URL错误: \(obj.backUrl)")
            return
        }
        
        print("开始下载身份证图片: \(obj.name)")
        let group = DispatchGroup()
        let manager = KingfisherManager.shared
        group.enter()
        manager.retrieveImage(with: frontUrl) { (result) in
            switch result {
            case .success(let res):
                obj.frontImage = res.image
            case .failure(let error):
                print("下载身份证国徽面图片失败: \(error)")
            }
            group.leave()
        }
        
        group.enter()
        manager.retrieveImage(with: backUrl) { (result) in
            switch result {
            case .success(let res):
                obj.backImage = res.image
            case .failure(let error):
                print("下载身份证人像面图片失败: \(error)")
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(obj.frontImage != nil && obj.backImage != nil)
        }
    }
}
