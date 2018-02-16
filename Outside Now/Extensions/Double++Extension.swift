//
//  Double++Extension.swift
//  Outside Now
//
//  Created by Dave on 2/14/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

extension Double {
    
    var stringRepresentation: String? {
        let formatter = NumberFormatter()
        // Rounds the number and removes the trailing zeros from the string representation
        //
        formatter.maximumFractionDigits = 0
        let formatedString = formatter.string(from: NSNumber(value: self))
        return formatedString
    }
    
    var percentString: String? {
        let formatter = NumberFormatter()
        // Use the formatter to add a % symbol and convert the decimal into a percent
        //
        formatter.numberStyle = .percent
        let formattedString = formatter.string(from: NSNumber(value: self))
        return formattedString
    }
}
