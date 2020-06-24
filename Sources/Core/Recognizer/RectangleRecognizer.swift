//
//  RectangleRecognizer.swift
//  CardsRecognizer
//
//  Created by 蒋惠 on 2020/6/24.
//

import UIKit
import Vision

final class RectangleRecognizer {
    
    let image: UIImage
    let completion: (Result<[UIImage], CardsRecognizerError>) -> Void
    
    init(image: UIImage, completion: @escaping (Result<[UIImage], CardsRecognizerError>) -> Void) {
        self.image = image
        self.completion = completion
    }
}

// MARK: - Vision request and handle
extension RectangleRecognizer {
    
    func recognize() {
        let requests = [getRectangleDetectionRequest()]
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        do {
            try handler.perform(requests)
        } catch let error as NSError {
            print("Failed to perform image request: \(error)")
            completion(.failure(CardsRecognizerError.invalidRequest))
            return
        }
    }
    
    /// Rectangle request
    private func getRectangleDetectionRequest() -> VNDetectRectanglesRequest  {
        let request = VNDetectRectanglesRequest(completionHandler: self.handleDetectedRectangles)
        // Customize & configure the request to detect only certain rectangles.
        request.maximumObservations = 8 // Vision currently supports up to 16.
        request.minimumConfidence = 0.6 // Be confident.
        request.minimumAspectRatio = 0.3 // height / width
        return request
    }
    
    /// Rectangle handle
    private func handleDetectedRectangles(request: VNRequest, error: Error?) {
        if let nsError = error as NSError? {
            print("Rectangle Detection Error: \(nsError)")
            completion(.failure(CardsRecognizerError.detectRectanglesFailed))
            return
        }
        guard let results = request.results as? [VNRectangleObservation] else {
            completion(.failure(CardsRecognizerError.detectRectanglesFailed))
            return
        }
        
        var cropImages: [UIImage] = []
        for observation in results {
            let rectBox = Helper.boundingBox(forRegionOfInterest: observation.boundingBox, withinImageSize: image.size)
            guard let cropImage = Helper.crop(image: image, rect: rectBox) else { return }
            cropImages.append(cropImage)
        }
        
        if cropImages.isEmpty {
            completion(.failure(CardsRecognizerError.detectRectanglesFailed))
        } else {
            completion(.success(cropImages))
        }
    }
}
