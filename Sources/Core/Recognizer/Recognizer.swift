//
//  Recognizer.swift
//  CardsRecognizer
//
//  Created by 蒋惠 on 2020/6/24.
//

import UIKit
import Vision

public class Recognizer {
    
    let image: UIImage
    let completion: (Result<[IDCard], CardsRecognizerError>) -> Void
    
    var results: [IDCard] = []
    
    init(image: UIImage, completion: @escaping (Result<[IDCard], CardsRecognizerError>) -> Void) {
        self.image = image
        self.completion = completion
    }
}

// MARK: - Public
extension Recognizer {
    
    public static func recognizeIDCard(source: RecognizeSource, completion: @escaping (Result<[IDCard], CardsRecognizerError>) -> Void) {
        let image: UIImage
        do {
            image = try source.getImage()
        } catch {
            completion(.failure(error as! CardsRecognizerError))
            return
        }
        Recognizer(image: image, completion: completion).recognizeIDCard()
    }
}

// MARK: - Recognize ID Card
extension Recognizer {
    
    private func recognizeIDCard() {
        RectangleRecognizer(image: image) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let images):
                self.didGetRectangle(images: images)
            case .failure(let error):
                self.completion(.failure(error))
            }
        }.recognize()
    }
    
    private func didGetRectangle(images: [UIImage]) {
        DispatchQueue.global().async {
            let semaphore = DispatchSemaphore(value: 1)
            for image in images {
                semaphore.wait()
                self.recognizeIDCard(image: image) { (success) in
                    semaphore.signal()
                }
            }
        }
    }
    
    private func recognizeIDCard(image: UIImage, completion: @escaping ((Bool) -> Void)) {
        // TODO: Rotation if needed
        let customWords = ["姓 名", "性 别", "名 族", "出 生", "住 址", "公民身份号码", "签发机关", "有效期限"]
        TextRecognizer(image: image, customWords: customWords) { (result) in
            switch result {
            case .success(let strings):
                let card = IDCard.createIDCard(by: strings)
                // TODO:
                completion(true)
                self.completion(.success([card]))
            case .failure(let error):
                print("Text Recognizer failed: \(error)")
                completion(false)
            }
        }.recognize()
    }
    
    private func didGetText(results: [String]) {
        
    }
}
