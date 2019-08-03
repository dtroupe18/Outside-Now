//
//  Forecast.swift
//  Outside Now
//
//  Created by Dave Troupe on 8/3/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import Foundation

// MARK: - Forcast
struct Forecast: Codable {
    let minutely: Minutely
    let currently: Currently
    let latitude: Double
    let offset: Int
    let longitude: Double
    let flags: Flags
    let daily: Daily
    let timezone: String
    let hourly: Hourly
    let alerts: [Alert]?
}

// MARK: - Alert
struct Alert: Codable {
    let title: String
    let time, expires: Int
    let alertDescription: String
    let uri: String

    enum CodingKeys: String, CodingKey {
        case title, time, expires
        case alertDescription = "description"
        case uri
    }
}

// MARK: - Currently
struct Currently: Codable {
    let apparentTemperature, pressure, precipIntensity: Double
    let time: Int
    let windSpeed, windGust: Double
    let summary: String
    let temperature: Double
    let uvIndex: Int
    let icon: IconName
    let nearestStormDistance: Int?
    let visibility, humidity, dewPoint: Double
    let precipType: PrecipType?
    let windBearing: Int
    let cloudCover, ozone, precipProbability: Double
    let precipIntensityError: Double?
}

// MARK: - ICON NAMES
enum IconName: String, Codable {
    case clearDay = "clear-day"
    case clearNight = "clear-night"
    case rain
    case snow
    case sleet
    case wind
    case fog
    case cloudy
    case partlyCloudyDay = "partly-cloudy-day"
    case partlyCloudyNight = "partly-cloudy-night"

    // Future
    case hail
    case thunderstorm
    case tornado
}

enum PrecipType: String, Codable {
    case rain
    case snow
    case sleet
}

// MARK: - Daily
struct Daily: Codable {
    let summary: String
    let icon: IconName
    let data: [DailyData]
}

// MARK: - DailyDatum
struct DailyData: Codable {
    let icon: IconName
    let windGustTime, temperatureLowTime: Int
    let dewPoint: Double
    let summary: String
    let temperatureMax, humidity, windGust, precipIntensityMax: Double
    let cloudCover, ozone: Double
    let apparentTemperatureMinTime, precipIntensityMaxTime, sunriseTime: Int
    let precipIntensity, windSpeed: Double
    let apparentTemperatureHighTime: Int
    let apparentTemperatureMin, apparentTemperatureHigh: Double
    let apparentTemperatureLowTime: Int
    let precipProbability: Double
    let temperatureHighTime: Int
    let pressure: Double
    let sunsetTime, windBearing, temperatureMinTime: Int
    let temperatureLow, temperatureHigh: Double
    let uvIndexTime: Int
    let apparentTemperatureMax: Double
    let apparentTemperatureMaxTime: Int
    let visibility, moonPhase, apparentTemperatureLow: Double
    let time: Int
    let precipType: PrecipType?
    let uvIndex: Int
    let temperatureMin: Double
    let temperatureMaxTime: Int
}

// MARK: - Flags
struct Flags: Codable {
    let sources: [String]
    let units: String
    let nearestStation: Double

    enum CodingKeys: String, CodingKey {
        case sources, units
        case nearestStation = "nearest-station"
    }
}

// MARK: - Hourly
struct Hourly: Codable {
    let summary: String
    let icon: IconName
    let data: [Currently]
}

// MARK: - Minutely
struct Minutely: Codable {
    let summary: String
    let icon: IconName
    let data: [MinutelyData]
}

// MARK: - MinutelyDatum
struct MinutelyData: Codable {
    let precipIntensityError: Double
    let precipType: PrecipType
    let precipIntensity: Double
    let time: Int
    let precipProbability: Double
}
