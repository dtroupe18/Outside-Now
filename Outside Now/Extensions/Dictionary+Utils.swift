//
//  Dictionary+Utils.swift
//  Outside Now
//
//  Created by Dave Troupe on 8/3/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import Foundation

extension Dictionary {
    /// get Dictionary as pretty printed JSON
    /// - warning: returns "invalid JSON" is JSON is not properly formated
    var asJSON: String {
        let invalidJson = "invalid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
}
