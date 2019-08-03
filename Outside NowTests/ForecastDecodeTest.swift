//
//  ForecastDecodeTest.swift
//  Outside NowTests
//
//  Created by Dave Troupe on 8/3/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import XCTest
@testable import Outside_Now

class ForecastDecodeTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecode() {
        let bundle: Bundle = Bundle(for: type(of: self))
        let path: String = bundle.path(forResource: "ForecastResponse", ofType: "json")!
        let url: URL = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)

        let forecast = try! JSONDecoder().decode(Forecast.self, from: data)

//        let currently = forecast.currently
//        let daily = forecast.daily
//        let hourly = forecast.hourly
//        let minutely = forecast.minutely
//        let flags = forecast.flags

        XCTAssertNil(forecast.alerts)
        XCTAssertEqual(forecast.offset, -7)
        XCTAssertEqual(forecast.latitude, 37.785834000000001)
        XCTAssertEqual(forecast.longitude,  -122.406417)
        XCTAssertEqual(forecast.timezone, "America/Los_Angeles")


        XCTAssertEqual(forecast.currently.summary, "Mostly Cloudy")
    }

    func testDecodeWithAlert() {
        let bundle: Bundle = Bundle(for: type(of: self))
        let path: String = bundle.path(forResource: "ForecastResponseWithAlert", ofType: "json")!
        let url: URL = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)

        let forecast = try! JSONDecoder().decode(Forecast.self, from: data)

//        let currently = forecast.currently
//        let daily = forecast.daily
//        let hourly = forecast.hourly
//        let minutely = forecast.minutely
//        let flags = forecast.flags

        XCTAssertNotNil(forecast.alerts)
        XCTAssertFalse(forecast.alerts!.isEmpty)

        XCTAssertEqual(forecast.offset, -7)
        XCTAssertEqual(forecast.latitude, 37.785834000000001)
        XCTAssertEqual(forecast.longitude,  -122.406417)
        XCTAssertEqual(forecast.timezone, "America/Los_Angeles")


        XCTAssertEqual(forecast.currently.summary, "Mostly Cloudy")
    }
}
