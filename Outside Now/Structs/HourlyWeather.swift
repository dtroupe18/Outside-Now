//
//  HourlyWeather.swift
//  Outside Now
//
//  Created by Dave on 2/14/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import SwiftyJSON

struct HourlyWeather {
    
    var temperature: Double
    let precipProbability: Double
    let iconName: String
    let time: Double
    
    init(json: JSON) {
        // Takes the response at "hourly"-> "data" -> List
        //
        self.temperature = json["temperature"].doubleValue
        self.precipProbability = json["precipProbability"].doubleValue
        self.iconName = json["icon"].stringValue
        self.time = json["time"].doubleValue
    }
}
