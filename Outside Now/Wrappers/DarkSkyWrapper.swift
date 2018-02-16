//
//  DarkSkyWrapper.swift
//  Outside Now
//
//  Created by Dave on 2/14/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SwiftIcons


class DarkSkyWrapper {
    
    static let shared = DarkSkyWrapper()
    var response: JSON?
    
    func getForecast(lat: Double, long: Double, completionHandler: @escaping ([Weather]?, [HourlyWeather]?, Error?) -> ()) {
        if let apiKey = AppDelegate.shared()?.keys?["DarkSkyKey"] {
            DispatchQueue.global(qos: .utility).async {
                Alamofire.request("https://api.darksky.net/forecast/\(apiKey)/\(lat),\(long)").responseJSON { (responseData) -> Void in
                    
                    if let error = responseData.result.error as? AFError {
                        let err = NSError(domain: "Weather Request Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "\(error.localizedDescription)"])
                        completionHandler(nil, nil, err)
                    }
                        
                    else if responseData.result.value != nil {
                        var weatherArray = [Weather]()
                        let swiftyJson = JSON(responseData.result.value!)
                        // Save the response
                        //
                        self.response = swiftyJson
                        // print("Full Response: \(swiftyJson)")
                        let currentWeather = Weather(fullJson: swiftyJson)
                        weatherArray.append(currentWeather)
                        
                        // Get Weather for the week
                        var first = true
                        for day in swiftyJson["daily"]["data"].arrayValue {
                            if first {
                                first = false
                                continue
                            }
                            let dailyWeather = Weather(json: day)
                            weatherArray.append(dailyWeather)
                            // print("dailyWeather: \(dailyWeather)")
                        }
                        
                        // Get Hourly Weather
                        //
                        var hourlyWeatherArray = [HourlyWeather]()
                        for hour in swiftyJson["hourly"]["data"].arrayValue {
                            let hourlyWeather = HourlyWeather(json: hour)
                            hourlyWeatherArray.append(hourlyWeather)
                        }
                        completionHandler(weatherArray, hourlyWeatherArray, nil)
                    }
                }
            }
        }
    }
    
    func getWeeklySummary() -> String? {
        if let json = response {
            return json["daily"]["summary"].stringValue
        }
        return nil
    }
    
    func getAlerts() -> String? {
        if let json = response {
            return json["alerts"]["title"].stringValue
        }
        return nil
    }
    
    static func convertIconNameToImage(iconName: String) -> UIImage {
        switch iconName {
        case "clear-day":
            return UIImage.init(icon: .weather(.daySunny), size: CGSize(width: 40, height: 42), textColor: .white, backgroundColor: .clear)
        case "clear-night":
            return UIImage.init(icon: .weather(.nightClear), size: CGSize(width: 40.0, height: 42.0), textColor: .white, backgroundColor: .clear)
        case "partly-cloudy-day":
            return UIImage.init(icon: .weather(.dayCloudy), size: CGSize(width: 40.0, height: 42.0), textColor: .white, backgroundColor: .clear)
        case "partly-cloudy-night":
            return UIImage.init(icon: .weather(.nightCloudy), size: CGSize(width: 40.0, height: 42.0), textColor: .white, backgroundColor: .clear)
        case "cloudy":
            return UIImage.init(icon: .weather(.cloudy), size: CGSize(width: 40.0, height: 42.0), textColor: .white, backgroundColor: .clear)
        case "rain":
            return UIImage.init(icon: .weather(.rain), size: CGSize(width: 40.0, height: 42.0), textColor: .white, backgroundColor: .clear)
        case "sleet":
            return UIImage.init(icon: .weather(.sleet), size: CGSize(width: 40.0, height: 42.0), textColor: .white, backgroundColor: .clear)
        case "snow":
            return UIImage.init(icon: .weather(.snow), size: CGSize(width: 40.0, height: 42.0), textColor: .white, backgroundColor: .clear)
        case "wind":
            return UIImage.init(icon: .weather(.windy), size: CGSize(width: 40.0, height: 42.0), textColor: .white, backgroundColor: .clear)
        case "fog":
            return UIImage.init(icon: .weather(.fog), size: CGSize(width: 40.0, height: 42.0), textColor: .white, backgroundColor: .clear)
        default:
            return UIImage.init(icon: .weather(.na), size: CGSize(width: 40.0, height: 42.0), textColor: .white, backgroundColor: .clear)
        }
    }
    
    static func convertTimestampToHour(seconds: Double) -> String {
        // Convert seconds to a string representing that hour
        //
        let date = Date(timeIntervalSince1970: seconds)
        let formatter = DateFormatter()
        // "a" prints "pm" or "am"
        //
        formatter.dateFormat = "h a"
        let hourString = formatter.string(from: date)
        return hourString
    }
    
    static func convertTimestampToDayName(seconds: Double) -> String {
        // Converts seconds to the string day of the week
        //
        let date = Date(timeIntervalSince1970: seconds)
        let format = "EEEE"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

