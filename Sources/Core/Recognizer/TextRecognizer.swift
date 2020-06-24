//
//  TextRecognizer.swift
//  CardsRecognizer
//
//  Created by 蒋惠 on 2020/6/24.
//

import UIKit
import Vision

final class TextRecognizer {
    
    let image: UIImage
    let customWords: [String]
    let completion: (Result<[String], CardsRecognizerError>) -> Void
    
    init(image: UIImage, customWords: [String], completion: @escaping (Result<[String], CardsRecognizerError>) -> Void) {
        self.image = image
        self.customWords = customWords
        self.completion = completion
    }
}

// MARK: - Vision request and handle
extension TextRecognizer {
    
    func recognize() {
        let requests = [getTextDetectionRequest()]
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        do {
            try handler.perform(requests)
        } catch let error as NSError {
            print("Failed to perform image request: \(error)")
            completion(.failure(CardsRecognizerError.invalidRequest))
            return
        }
    }
    
    /// Text request
    private func getTextDetectionRequest() -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["zh-Hans"]
        request.customWords = customWords
        return request
    }
    
    /// Text handle
    private func handleDetectedText(request: VNRequest, error: Error?) {
        if let nsError = error as NSError? {
            print("Text Detection Error: \(nsError)")
            completion(.failure(CardsRecognizerError.detectTextsFailed))
            return
        }
        guard let results = request.results as? [VNRecognizedTextObservation] else {
            completion(.failure(CardsRecognizerError.detectTextsFailed))
            return
        }
        
        var strings:[String] = []
        for observation in results {
            // 把识别的文字全部连成一个string
            guard let candidate = observation.topCandidates(1).first else { continue }
            strings.append(candidate.string)
        }
        completion(.success(strings))
    }
}
