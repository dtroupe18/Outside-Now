//
//  DailySummary.swift
//  Outside Now
//
//  Created by Dave on 2/22/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import SwiftyJSON

struct DailySummary {
    
    let summary: String
    let sunriseTime: Double
    let sunsetTime: Double
    
    init(fullJson: JSON) {
        self.summary = fullJson["hourly"]["summary"].stringValue
        self.sunriseTime = fullJson["daily"]["data"][0]["sunriseTime"].doubleValue
        self.sunsetTime = fullJson["daily"]["data"][0]["sunsetTime"].doubleValue
    }
}
