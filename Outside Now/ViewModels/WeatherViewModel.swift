//
//  WeatherViewModel.swift
//  Outside Now
//
//  Created by Dave Troupe on 8/4/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import Foundation

protocol WeatherViewModelViewDelegate: class {
    func gotForecast()
    func gotError(_ error: Error)
}

protocol WeatherViewModelProtocol: class {
    var viewDelegate: WeatherViewModelViewDelegate? { get set}

    func getForecast(lat: Double, long: Double)
    func getFutureForecast(lat: Double, long: Double, time: Int)

    init(networkClient: NetworkClient)
}

final class WeatherViewModel: WeatherViewModelProtocol {
    weak var viewDelegate: WeatherViewModelViewDelegate?

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func getForecast(lat: Double, long: Double) {
        self.networkClient.getForecast(lat: lat, long: long, onSuccess: { [weak self] forecast in
            self?.viewDelegate?.gotForecast()
        }, onError: { [weak self] error in
            self?.viewDelegate?.gotError(error)
        })
    }

    func getFutureForecast(lat: Double, long: Double, time: Int) {
        self.networkClient.getFutureForecast(lat: lat, long: long, formattedTime: "\(time)", onSuccess: { [weak self] forecast in
            self?.viewDelegate?.gotForecast()
        }, onError: { [weak self] error in
            self?.viewDelegate?.gotError(error)
        })
    }
}
