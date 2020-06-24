//
//  Helper.swift
//  CardsRecognizer
//
//  Created by 蒋惠 on 2020/6/24.
//

import UIKit

struct Helper {
    
    static func boundingBox(forRegionOfInterest: CGRect, withinImageBounds bounds: CGRect) -> CGRect {
        let imageWidth = bounds.width
        let imageHeight = bounds.height
        
        // Begin with input rect.
        var rect = forRegionOfInterest
        
        // Reposition origin.
        rect.origin.x *= imageWidth
        rect.origin.x += bounds.origin.x
        rect.origin.y = (1 - rect.origin.y) * imageHeight + bounds.origin.y
        
        // Rescale normalized coordinates.
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight
        
        rect.origin.y -= rect.size.height
        
        return rect
    }
    
    static func boundingBox(forRegionOfInterest: CGRect, withinImageSize size:CGSize) -> CGRect {
        // Begin with input rect.
        var rect = forRegionOfInterest
        
        // Reposition origin.
        rect.origin.x *= size.width
        rect.origin.y = (1 - rect.origin.y) * size.height
        
        // Rescale normalized coordinates.
        rect.size.width *= size.width
        rect.size.height *= size.height
        
        rect.origin.y -= rect.size.height
        
        return rect
    }
    
    static func crop(image: UIImage, rect: CGRect) -> UIImage? {
        guard let source = image.cgImage else { return nil }
        guard let cgImage = source.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    static func fomatData(dateStr: String, from fromFormat: String, to toFormat: String) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = fromFormat
        guard let date = dateFormat.date(from: dateStr) else { return "" }
        dateFormat.dateFormat = toFormat
        return dateFormat.string(from: date)
    }
}
