//
//  RecognizeSource.swift
//  CardsRecognizer
//
//  Created by 蒋惠 on 2020/6/24.
//

import UIKit

public protocol RecognizeSource {
    
    func getImage() throws -> UIImage
}

extension UIImage: RecognizeSource {
    
    public func getImage() throws -> UIImage {
        return self
    }
}

extension URL: RecognizeSource {

    public func getImage() throws -> UIImage {
        guard isFileURL else {
            throw CardsRecognizerError.invalidURL
        }
        guard let data = try? Data(contentsOf: self) else {
            throw CardsRecognizerError.invalidData
        }
        guard let image = UIImage(data: data) else {
            throw CardsRecognizerError.invalidImage
        }
        return image
    }
}
