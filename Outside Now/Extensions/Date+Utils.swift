//
//  Date+Utils.swift
//  Outside Now
//
//  Created by Dave on 2/16/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSinceEpoch: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}
