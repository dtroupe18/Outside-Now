//
//  DarkSkyWrapper.swift
//  Outside Now
//
//  Created by Dave on 2/14/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias ForecastCallback = (Forecast) -> Void
typealias ErrorCallback = (Error) -> Void

final class DarkSkyWrapper {
    
    static let shared = DarkSkyWrapper()
    var response: JSON?
    
    var responses = [String: [String: Any]]() // qwe make json a type alias

    private let path = Bundle.main.path(forResource: "Keys", ofType: "plist")!

    private var apiKey: String {
        return NSDictionary(contentsOfFile: path)!.value(forKey: "DarkSkyKey") as! String
    }

    private func makeErrorWithDescription(_ description: String) -> Error {
        return NSError(
            domain: "Weather Request Error",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "\(description)"]
        ) as Error
    }

    func getFutureForecast(
        lat: Double,
        long: Double,
        formattedTime: String,
        onSuccess: ForecastCallback?,
        onError: ErrorCallback?
    ) {

        Alamofire.request(
            "https://api.darksky.net/forecast/\(apiKey)/\(lat),\(long),\(formattedTime)")
            .responseJSON(completionHandler: { (response) -> Void in

                if let error = response.result.error as? AFError {
                    let err = self.makeErrorWithDescription(error.localizedDescription)
                    onError?(err)
                    return
                }

                if let data = response.data {
                    do {
                        let forecast = try JSONDecoder().decode(Forecast.self, from: data)
                        onSuccess?(forecast)
                    } catch let err {
                        // FIXME: Make this error generic
                        let error = self.makeErrorWithDescription(err.localizedDescription)
                        onError?(error)
                    }
                }
        })
    }

    func getForecast(lat: Double, long: Double, onSuccess: ForecastCallback?, onError: ErrorCallback?) {
        self.responses.removeAll()

        // WEAK SELF oho
        Alamofire.request("https://api.darksky.net/forecast/\(apiKey)/\(lat),\(long)").responseJSON { (response) -> Void in

            if let error = response.result.error as? AFError {
                let err = self.makeErrorWithDescription(error.localizedDescription)
                onError?(err)
                return
            }

            if let data = response.data {
                do {
                    let forecast = try JSONDecoder().decode(Forecast.self, from: data)
                    onSuccess?(forecast)
                } catch let err {
                    // FIXME: Make this error generic
                    let error = self.makeErrorWithDescription(err.localizedDescription)
                    onError?(error)
                }
            } else {
                // FIXME: Update copy
                let error = self.makeErrorWithDescription("NO DATA")
                onError?(error)
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
            // Account for moon phase
            //
            return #imageLiteral(resourceName: "clear-night")
        case "partly-cloudy-day":
            return #imageLiteral(resourceName: "partly-cloudy-day")
        case "partly-cloudy-night":
            // Account for moon phase
            //
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
        // Function draws text on an image
        //
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
    
    static func convertTimestampToHour(seconds: Double, timeZone: TimeZone?) -> String {
        // Convert seconds to a string representing that hour
        //
        let date = Date(timeIntervalSince1970: seconds)
        let formatter = DateFormatter()
        // "a" prints "pm" or "am"
        //
        if let zone = timeZone {
            formatter.timeZone = zone
        }
        formatter.dateFormat = "h a"
        let hourString = formatter.string(from: date)
        return hourString
    }
    
    static func convertTimestampToHourMin(seconds: Double, timeZone: TimeZone?) -> String {
        // Convert seconds to a string representing that hour
        //
        let date = Date(timeIntervalSince1970: seconds)
        let formatter = DateFormatter()
        if let zone = timeZone {
            formatter.timeZone = zone
        }
        // "a" prints "pm" or "am"
        //
        formatter.dateFormat = "h:mm a"
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
    
    static func convertTimestampToDayDate(seconds: Double, fullString: Bool = true) -> String {
        // Converts seconds to the string day of the week plus date ex: "Sat 24"
        //
        let date = Date(timeIntervalSince1970: seconds)
        // format is full day string, full month, two digit day
        // Ex: "Monday March 26"
        //
        let dayFormat = "EEEE"
        let formatter = DateFormatter()
        formatter.dateFormat = dayFormat
        let dayString = formatter.string(from: date)
        
        let monthDayFormat = "MMMM d"
        formatter.dateFormat = monthDayFormat
        let monthDayString = formatter.string(from: date)
        
        if fullString {
            return "\(dayString)\n\(monthDayString)"
        } else {
            // Return just the month and day for "Today" case in daily weather
            //
            return "\(monthDayString)"
        }
    }
}

