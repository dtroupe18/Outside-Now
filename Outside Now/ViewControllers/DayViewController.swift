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
    @IBOutlet weak var dailySummaryLabel: UILabel!
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
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    var placemark: CLPlacemark!
    var forcast: Forecast! // FIXME: use VM
    var currentIndex: Int = -1
    var locationString: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.black
        // Remove lines between tableview cells
        //
        tableView.separatorStyle = .none
        
        updateView()
         
        locationLabel.text = locationString
        sunsetImageView.image = #imageLiteral(resourceName: "SunsetImage")
        sunriseImageView.image = #imageLiteral(resourceName: "SunriseImage")
        
        // Add a dividing line at the bottom of the headerView
        //
        let border = CALayer()
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: header.frame.size.height - 3, width: header.frame.size.width, height: 1.0)
        border.borderWidth = CGFloat(1.0)
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
    
    @IBAction func nextPressed(_ sender: Any) { 
        // Get the daily forecast for the next day and update the view
        //
        if currentIndex + 1 < forcast.daily.data.count {
            currentIndex += 1
            updateView()
        }
    }
    
    @IBAction func previousPressed(_ sender: Any) {
        if currentIndex - 1 >= 0 {
            currentIndex -= 1
            updateView()
        }
    }
        
    // Update everything related to weather data
    //
    func updateView() {
        if currentIndex >= 0 && currentIndex < forcast.daily.data.count {
            let weather = forcast.daily.data[currentIndex]
            self.summaryLabel.text = weather.summary

            let sunriseTime = weather.sunriseTime.asDouble
            let sunsetTime = weather.sunsetTime.asDouble

            self.sunriseLabel.text = DarkSkyWrapper.convertTimestampToHourMin(seconds: sunriseTime, timeZone: self.placemark.timeZone)
            self.sunsetLabel.text = DarkSkyWrapper.convertTimestampToHourMin(seconds: sunsetTime, timeZone: self.placemark.timeZone)

            if self.currentIndex > 0 {
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
            
            if currentIndex > 0 {
                let dateString = DarkSkyWrapper.convertTimestampToDayDate(seconds: weather.time.asDouble)
                dayLabel.text = dateString
            } else if currentIndex == 0 {
                let monthDayString = DarkSkyWrapper.convertTimestampToDayDate(seconds: weather.time.asDouble, fullString: false)
                dayLabel.text = "Today\n\(monthDayString)"
                scrollTableViewToCurrentHour()
            }
            
            // Make "High" & "Low" bold on their labels
            //
            let attribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
            let attributedHi = NSMutableAttributedString(string:  "High  ", attributes: attribute)
            let attributedLow = NSMutableAttributedString(string: "Low   ", attributes: attribute)
            let attributedHiTemp = NSMutableAttributedString(string: "\(weather.temperatureHigh.stringRepresentation ?? "")°")
            let attributedLowTemp = NSMutableAttributedString(string: "\(weather.temperatureLow.stringRepresentation ?? "")°")
            
            attributedHi.append(attributedHiTemp)
            attributedLow.append(attributedLowTemp)
            
            hiLabel.attributedText = attributedHi
            loLabel.attributedText = attributedLow
            self.tableView.reloadData()
        }
    }
    
    func scrollTableViewToCurrentHour() {
        var calendar = Calendar.current
        // use the correct timeZone
        //
        if let zone = placemark.timeZone {
            calendar.timeZone = zone
        }
        let hour = calendar.component(.hour, from: Date())
        let indexPath = IndexPath(row: hour, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
    // MARK: Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forcast.hourly.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "enhancedHourlyCell", for: indexPath) as! HourlyTableViewCell
        
        cell.timeLabel.text = DarkSkyWrapper.convertTimestampToHour(seconds: forcast.hourly.data[indexPath.row].time.asDouble, timeZone: placemark.timeZone)
        cell.condImageView.image = DarkSkyWrapper.convertIconNameToImage(iconName: forcast.hourly.data[indexPath.row].icon.rawValue)
        cell.tempLabel.text = "\(forcast.hourly.data[indexPath.row].temperature.stringRepresentation ?? "")°"
        cell.precipLabel.text = forcast.hourly.data[indexPath.row].precipProbability.percentString
        cell.windLabel.text = forcast.hourly.data[indexPath.row].windSpeed.windSpeedString
        cell.selectionStyle = .none
        return cell
    }
}
