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
        print("image size: \(image.size)")
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
            let group = DispatchGroup()
            for image in images {
                group.enter()
                self.recognizeIDCard(image: image) { (success) in
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                if self.results.isEmpty {
                    self.completion(.failure(CardsRecognizerError.recognizeFailed))
                } else {
                    self.completion(.success(self.results))
                }
            }
        }
    }
    
    private func recognizeIDCard(image: UIImage, end: Bool = false, completion: @escaping ((Bool) -> Void)) {
        let customWords = ["姓名", "性别", "名族", "出生", "住址", "公民身份号码", "签发机关", "有效期限", "公安局", "分局"]
        if image.size.height <= image.size.width {
            TextRecognizer(image: image, customWords: customWords) { (result) in
                switch result {
                case .success(let strings):
                    let card = IDCard.createIDCard(by: strings)
                    if card.side == .unknown {
                        if end {
                            completion(false)
                        } else {
                            // 旋转180°
                            DispatchQueue.main.async {
                                print("Rotation 180")
                                if let newImage = Helper.transformImage(image: image, transform: .init(rotationAngle: CGFloat.pi)) {
                                    self.recognizeIDCard(image: newImage, end: true, completion: completion)
                                } else {
                                    completion(false)
                                }
                            }
                        }
                    } else {
                        self.results.append(card)
                        completion(true)
                    }
                case .failure(let error):
                    print("Text Recognizer failed: \(error)")
                    completion(false)
                }
            }.recognize()
        } else if !end {
            // 逆时针旋转90°
            DispatchQueue.main.async {
                print("Rotation 90")
                if let newImage = Helper.transformImage(image: image, transform: .init(rotationAngle: -CGFloat.pi/2)) {
                    self.recognizeIDCard(image: newImage, end: false, completion: completion)
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    private func didGetText(results: [String]) {
        
    }
}
