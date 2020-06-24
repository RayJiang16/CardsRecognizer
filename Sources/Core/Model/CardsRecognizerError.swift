//
//  CardsRecognizerError.swift
//  CardsRecognizer
//
//  Created by 蒋惠 on 2020/6/24.
//

import Foundation

public enum CardsRecognizerError: Error {
    
    case invalidURL
    case invalidData
    case invalidImage
    case invalidRequest
    
    case detectRectanglesFailed
    case detectTextsFailed
    case recognizeFailed
}
