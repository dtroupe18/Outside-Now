//
//  CurrentWeather.swift
//  Outside Now
//
//  Created by Dave on 2/14/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Weather {
    
    let lowTemp: Double
    var currentTemp: Double?
    let highTemp: Double
    let windSpeed: Double
    let precipProbability: Double
    let summary: String
    let iconName: String
    let time: Double
    
    init(json: JSON) {
        // Takes the response at "daily"-> "data" -> List
        //
        self.lowTemp = json["temperatureLow"].doubleValue
        self.highTemp = json["temperatureHigh"].doubleValue
        self.windSpeed = json["windSpeed"].doubleValue
        self.precipProbability = json["precipProbability"].doubleValue
        self.summary = json["summary"].stringValue
        self.iconName = json["icon"].stringValue
        self.time = json["time"].doubleValue
    }
    
    init(fullJson: JSON) {
        // Takes the full response from DarkSky
        //
        self.currentTemp = fullJson["currently"]["temperature"].doubleValue
        self.lowTemp = fullJson["daily"]["data"][0]["temperatureLow"].doubleValue
        self.highTemp = fullJson["daily"]["data"][0]["temperatureHigh"].doubleValue
        self.precipProbability = fullJson["currently"]["precipProbability"].doubleValue
        self.windSpeed = fullJson["currently"]["windSpeed"].doubleValue
        self.iconName = fullJson["currently"]["icon"].stringValue
        self.time = fullJson["currently"]["time"].doubleValue
        
        // Hourly summary is a summary for all hours of the day
        //
        self.summary = fullJson["hourly"]["summary"].stringValue
        
        // print("Todays weather: \(self)")
    }
}
