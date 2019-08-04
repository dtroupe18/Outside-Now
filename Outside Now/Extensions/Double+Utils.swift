//
//  Double+Utils.swift
//  Outside Now
//
//  Created by Dave on 2/14/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

extension Double {

    /// Returns truncated (Int) string value
    var stringRepresentation: String? {
        let formatter = NumberFormatter() // qwe round
        formatter.maximumFractionDigits = 0
        let formatedString = formatter.string(from: NSNumber(value: self))
        return formatedString
    }

    /// Returns double as a string with percent %
    var percentString: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        let formattedString = formatter.string(from: NSNumber(value: self))
        return formattedString
    }

    // MARK: Timestamp helpers

    /// Returns h:mm am/pm time as a string
    /// - warning: self must be a unix timestamp
    func hourMinString(timeZone: TimeZone?) -> String {
        let date = Date(timeIntervalSince1970: self)
        let formatter = DateFormatter()

        if let zone = timeZone {
            formatter.timeZone = zone
        }

        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    /// Returns day month day number string EX: "Monday March 26" or "March 26"
    /// - warning: self must be a unix timestamp
    func monthDayString(includeDayName: Bool = true) -> String {
        let date = Date(timeIntervalSince1970: self)
        let dayFormat = "EEEE"

        let formatter = DateFormatter()
        formatter.dateFormat = dayFormat
        let dayString = formatter.string(from: date)

        let monthDayFormat = "MMMM d"
        formatter.dateFormat = monthDayFormat
        let monthDayString = formatter.string(from: date)

        if includeDayName {
            return "\(dayString)\n\(monthDayString)"
        } else {
            return "\(monthDayString)"
        }
    }

    /// Returns the hour as a string with am or pm after
    /// - warning: self must be a unix timestamp
    func hourString(timeZone: TimeZone?) -> String {
        let date = Date(timeIntervalSince1970: self)
        let formatter = DateFormatter()

        if let zone = timeZone {
            formatter.timeZone = zone
        }

        // "a" prints "pm" or "am"
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }



    /// Returns day name as a string
    /// - warning: self must be a unix timestamp
    func dayNameString() -> String {
        let date = Date(timeIntervalSince1970: self)
        let format = "EEEE"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
