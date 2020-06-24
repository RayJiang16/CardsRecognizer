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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func loadData() {
        readDataJsonFile()
        if !list.isEmpty {
            startTest()
        }
    }
    
    private func startTest() {
        print("Start test, test count: \(list.count)")
        for obj in list {
            downloadPhoto(obj: obj) { (success) in
                if !success { return }
                self.recognize(obj: obj)
            }
        }
    }
    
    private func recognize(obj: Persion) {
        print("Start recognize")
        Recognizer.recognizeIDCard(source: obj.frontImage!) { (result) in
            switch result {
            case .success(let card):
                print(card)
            case .failure(let error):
                print(error)
            }
        }
        
        Recognizer.recognizeIDCard(source: obj.backImage!) { (result) in
            switch result {
            case .success(let card):
                print(card)
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - Helper
extension ViewController {
    
    private func readDataJsonFile() {
        guard let dataPath = Bundle.main.path(forResource: "Data", ofType: "json") else {
            print("Data.json 文件不存在")
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
            print("身份证国徽面图片URL错误: \(obj.frontUrl)")
            return
        }
        guard let backUrl = URL(string: obj.backUrl) else {
            print("身份证人像面图片URL错误: \(obj.backUrl)")
            return
        }
        
        let group = DispatchGroup()
        let downloader = KingfisherManager.shared.downloader
        
        group.enter()
        downloader.downloadImage(with: frontUrl) { (result) in
            switch result {
            case .success(let res):
                obj.frontImage = res.image
            case .failure(let error):
                print("下载身份证国徽面图片失败: \(error)")
            }
            group.leave()
        }
        
        group.enter()
        downloader.downloadImage(with: backUrl) { (result) in
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
