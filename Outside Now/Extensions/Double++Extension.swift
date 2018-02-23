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
        // Rounds a Double and removes the trailing zeros from the string representation
        //
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        let formatedString = formatter.string(from: NSNumber(value: self))
        return formatedString
    }
    
    var percentString: String? {
        // Use the formatter to add a % symbol and convert a decimal (Double) into a percent
        //
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        let formattedString = formatter.string(from: NSNumber(value: self))
        return formattedString
    }
    
    var windSpeedString: String? {
        // Rounds a Double and removes the trailing zeros from the string representation
        // then we add MPH to the end
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        let formatedString = formatter.string(from: NSNumber(value: self))
        if var string = formatedString {
            string += " MPH"
            return string
        } else {
            return nil
        }
    }
}
