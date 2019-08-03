//
//  NetworkClient.swift
//  Outside Now
//
//  Created by Dave Troupe on 8/3/19.
//  Copyright © 2019 High Tree Development. All rights reserved.
//

import Foundation

private enum RequestError: String, Error {
    case noData = "No response from server please try again."
    case decodeFailed = "The server response is missing data. Please try again."

    func makeError() -> Error {
        return NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey : self.rawValue]) as Error
    }
}

typealias DataCallback = (Data) -> Void
typealias ErrorCallback = (Error) -> Void
typealias ForecastCallback = (Forecast) -> Void

struct NetworkClient {
    private let path = Bundle.main.path(forResource: "Keys", ofType: "plist")!

    private var apiKey: String {
        return NSDictionary(contentsOfFile: path)!.value(forKey: "DarkSkyKey") as! String
    }

    private let baseURL: String =  "https://api.darksky.net/forecast/"

    /// Make a get request at the url passed in
    /// - warning: Data or Error is not returned on the main thread
    private func makeGetRequest(urlAddition: String, onSuccess: DataCallback?, onError: ErrorCallback?) {
        let url = URL(string: "\(baseURL)\(urlAddition)")!
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default)

        let task = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                onError?(err)
                return
            }

            guard let data = data else {
                onError?(RequestError.noData.makeError())
                return
            }
            onSuccess?(data)
        }
        task.resume()
    }

    /// Returns Forecast struct or Error on the main thread for given latitude and longitude
    func getForecast(lat: Double, long: Double, onSuccess: ForecastCallback?, onError: ErrorCallback?) {
        self.makeGetRequest(urlAddition: "\(apiKey)/\(lat),\(long)", onSuccess: { data in
            do {
                let forecast = try JSONDecoder().decode(Forecast.self, from: data)
                DispatchQueue.main.async {
                    onSuccess?(forecast)
                }
            } catch {
                DispatchQueue.main.async {
                    onError?(RequestError.decodeFailed.makeError())
                }
                // FIXME: Log this error!
            }
        }, onError: { error in
            DispatchQueue.main.async {
                onError?(error)
            }
        })
    }
}
