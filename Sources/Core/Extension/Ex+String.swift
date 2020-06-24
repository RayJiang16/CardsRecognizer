//
//  Ex+String.swift
//  CardsRecognizer
//
//  Created by Ray on 2020/6/24.
//

import Foundation

extension String {
    
    var isEnglish: Bool {
        let pattern = "^[a-zA-Z]+$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self)
    }
}
