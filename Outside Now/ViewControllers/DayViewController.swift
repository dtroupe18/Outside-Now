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
    
    @IBOutlet weak var headerTimeLabel: UILabel!
    @IBOutlet weak var headerCondLabel: UILabel!
    @IBOutlet weak var headerTempLabel: UILabel!
    @IBOutlet weak var headerPrecipLabel: UILabel!
    @IBOutlet weak var headerWindLabel: UILabel!
    
    var placemark: CLPlacemark!
    var weather: Weather!
    var locationString: String!
    
    var hourlyWeather = [HourlyWeather]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.black
        // Remove lines between tableview cells
        //
        tableView.separatorStyle = .none
        
        if let location = placemark.location {
            getWeather(location: location)
        }
        
        dayLabel.text = DarkSkyWrapper.convertTimestampToDayName(seconds: weather.time)
        dayLabel.font = UIFont.boldSystemFont(ofSize: 22)
        locationLabel.text = locationString
        sunsetImageView.image = #imageLiteral(resourceName: "SunsetImage")
        sunriseImageView.image = #imageLiteral(resourceName: "SunriseImage")
        
        // Make "Hi: & Low: bold on their labels
        //
        let attribute = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)]
        let attributedHi = NSMutableAttributedString(string:  "High  ", attributes: attribute)
        let attributedLow = NSMutableAttributedString(string: "Low   ", attributes: attribute)
        let attributedHiTemp = NSMutableAttributedString(string: "\(weather.highTemp.stringRepresentation ?? "")°")
        let attributedLowTemp = NSMutableAttributedString(string: "\(weather.lowTemp.stringRepresentation ?? "")°")
        
        attributedHi.append(attributedHiTemp)
        attributedLow.append(attributedLowTemp)
    
        hiLabel.attributedText = attributedHi
        loLabel.attributedText = attributedLow
        
        // Add a dividing line at the bottom of the headerView
        //
        let border = CALayer()
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: header.frame.size.height - 3, width: header.frame.size.width, height: 1.0)
        border.borderWidth = CGFloat(2.0)
        header.layer.addSublayer(border)
        header.layer.masksToBounds = true
        
        // Use swipe to navigate the user back to the previous VC
        //
        let edgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.screenEdgeSwiped(recognizer:)))
        edgeSwipe.edges = .left
        view.addGestureRecognizer(edgeSwipe)
    }
    
    // Swipe to navigate back
    //
    @objc func screenEdgeSwiped(recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            self.navigationController?.popViewController(animated: true)
        }
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
        cell.tempLabel.text = "\(hourlyWeather[indexPath.row].temperature.stringRepresentation ?? "")°"
        cell.precipLabel.text = hourlyWeather[indexPath.row].precipProbability.percentString
        cell.windLabel.text = hourlyWeather[indexPath.row].windSpeed.windSpeedString
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
