//
//  DarkSkyWrapper.swift
//  Outside Now
//
//  Created by Dave on 2/14/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit

final class DarkSkyWrapper {

    
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
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
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

