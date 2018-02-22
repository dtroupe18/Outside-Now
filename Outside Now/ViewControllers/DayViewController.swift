//
//  DayWeatherViewController.swift
//  Outside Now
//
//  Created by Dave on 2/22/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import CoreLocation

class DayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var sunriseImageView: UIImageView!
    @IBOutlet weak var sunsetImageView: UIImageView!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var hiLabel: UILabel!
    @IBOutlet weak var loLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var header: UIView!
    
    var placemark: CLPlacemark!
    var weather: Weather!
    var locationString: String!
    
    var hourlyWeather = [HourlyWeather]()
    
    override func viewWillAppear(_ animated: Bool) {
        if let location = placemark.location {
            getWeather(location: location)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        dayLabel.text = DarkSkyWrapper.convertTimestampToDayName(seconds: weather.time)
        locationLabel.text = locationString
        sunsetImageView.image = #imageLiteral(resourceName: "SunsetImage")
        sunriseImageView.image = #imageLiteral(resourceName: "SunriseImage")
        hiLabel.text = "Hi \(weather.highTemp.stringRepresentation ?? "")"
        loLabel.text = "Lo \(weather.lowTemp.stringRepresentation ?? "")"
    }
    
    func getWeather(location: CLLocation) {
        if let formattedTime = weather.getFormattedTime() {
            DarkSkyWrapper.shared.getFutureForecast(lat: location.coordinate.latitude, long: location.coordinate.longitude, formattedTime: formattedTime, completionHandler: { (summary, hourlyArray, error) in
                
                if let err = error {
                    print(err.localizedDescription)
                }
                
                if let dailySummary = summary, let hourlyWeatherArray = hourlyArray {
                    self.summaryLabel.text = dailySummary.summary
                    self.sunriseLabel.text = DarkSkyWrapper.convertTimestampToHourMin(seconds: dailySummary.sunriseTime)
                    self.sunsetLabel.text = DarkSkyWrapper.convertTimestampToHourMin(seconds: dailySummary.sunsetTime)
                    
                    self.hourlyWeather = hourlyWeatherArray
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    // Marker: Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourlyWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "enhancedHourlyCell", for: indexPath) as! HourlyTableViewCell
        
        cell.timeLabel.text = DarkSkyWrapper.convertTimestampToHour(seconds: hourlyWeather[indexPath.row].time)
        cell.condImageView.image = DarkSkyWrapper.convertIconNameToImage(iconName: hourlyWeather[indexPath.row].iconName)
        cell.tempLabel.text = hourlyWeather[indexPath.row].temperature.stringRepresentation
        cell.precipLabel.text = hourlyWeather[indexPath.row].precipProbability.percentString
        cell.windLabel.text = String(hourlyWeather[indexPath.row].windSpeed)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}
