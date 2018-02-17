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
            return #imageLiteral(resourceName: "clear-day")
        case "clear-night":
            return #imageLiteral(resourceName: "clear-night")
        case "partly-cloudy-day":
            return #imageLiteral(resourceName: "partly-cloudy-day")
        case "partly-cloudy-night":
            return #imageLiteral(resourceName: "partly-cloudy-night")
        case "cloudy":
            return #imageLiteral(resourceName: "cloudy")
        case "rain":
            return #imageLiteral(resourceName: "rain")
        case "sleet":
            return #imageLiteral(resourceName: "sleet")
        case "snow":
            return #imageLiteral(resourceName: "snow")
        case "wind":
            return #imageLiteral(resourceName: "wind")
        case "fog":
            // Returns the cloudy image with "FOG" written below the cloud
            //
            if let annotatedImage = textToImage(drawText: "FOG", inImage: #imageLiteral(resourceName: "cloudy"), atPoint: CGPoint(x: 5, y: 28)) {
                return annotatedImage
            } else {
                return #imageLiteral(resourceName: "cloudy")
            }
        default:
            // Default value is error. Prevents issues if new images are added
            //
            return #imageLiteral(resourceName: "error")
        }
    }
    
    static func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage? {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica", size: 12)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            ] as [NSAttributedStringKey : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
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

