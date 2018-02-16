//
//  WeatherViewController.swift
//  Outside Now
//
//  Created by Dave on 2/14/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentSummaryLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var todayHiLabel: UILabel!
    @IBOutlet weak var todayLowLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var currentLocationPlacemark: CLPlacemark?
    
    var weatherArray = [Weather]()
    var hourlyWeather = [HourlyWeather]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if LocationWrapper.shared.canAccessLocation() {
            getPlacemark()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationWrapper.shared.locationManager.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = UIScreen.main.bounds.width
            let height = collectionView.bounds.height
            flow.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flow.minimumInteritemSpacing = 0
            flow.minimumLineSpacing = 0
            flow.itemSize = CGSize(width: width / 5, height: height)
        }
        
        collectionView.layer.borderWidth = 1
        collectionView.layer.borderColor = UIColor.lightGray.cgColor
        collectionView.backgroundColor = UIColor.black

        tableView.backgroundColor = UIColor.black
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Ask user for permission
        //
        if !LocationWrapper.shared.canAccessLocation() {
            if LocationWrapper.shared.authStatus != .denied {
                LocationWrapper.shared.locationManager.requestWhenInUseAuthorization()
            } else {
                showAlert(title: "Location Access Denied", message: "Without access to your location outside now can only provide weather if your search for a location. You can update location access in settings.")
            }
        }
    }
    
    // Marker: CLLocationManagerDelegate
    //
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        LocationWrapper.shared.authStatus = status
        if status == .denied {
            showAlert(title: "Location Access Denied", message: "Without access to your location outside now can only provide weather if your search for a location. You can update location access in settings.")
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            // Get the users location and then the weather
            //
            getPlacemark()
        }
    }
    
    // Marker: CollectionView Delegate
    //
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyWeather.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourlyCell", for: indexPath) as! HourlyCell
        
        if let temp = hourlyWeather[indexPath.row].temperature.stringRepresentation {
            cell.tempLabel.text = "\(temp)°"
        }
        if let precipPercent = hourlyWeather[indexPath.row].precipProbability.percentString {
            cell.precipLabel.text = precipPercent
        }
        cell.hourLabel.text = DarkSkyWrapper.convertTimestampToHour(seconds: hourlyWeather[indexPath.row].time)
        cell.tempLabel.textColor = UIColor.white
        cell.precipLabel.textColor = UIColor.white
        cell.hourLabel.textColor = UIColor.white
        return cell
    }
    
    // Marker: TableView Delegate
    //
    func numberOfSections(in tableView: UITableView) -> Int {
        if weatherArray.isEmpty {
            return 0
        } else {
            return weatherArray.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Show the weekly summary cell
            //
            let cell = tableView.dequeueReusableCell(withIdentifier: "weeklySummaryCell", for: indexPath) as! WeeklySummaryCell
            if let summary = DarkSkyWrapper.shared.getWeeklySummary() {
                cell.summaryLabel.text = summary
                cell.backgroundColor = UIColor.black
                cell.summaryLabel.textColor = UIColor.white
            } else {
                cell.isHidden = true
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherCell
            cell.dayLabel.text = DarkSkyWrapper.convertTimestampToDayName(seconds: weatherArray[indexPath.row].time)
            cell.hiLabel.text = weatherArray[indexPath.row].highTemp.stringRepresentation
            cell.lowLabel.text = weatherArray[indexPath.row].lowTemp.stringRepresentation
            cell.backgroundColor = UIColor.black
            cell.dayLabel.textColor = UIColor.white
            cell.hiLabel.textColor = UIColor.white
            cell.lowLabel.textColor = UIColor.white
            return cell
        }
    }
    
    // Marker: Location
    //
    func getPlacemark() {
        LocationWrapper.shared.getPlaceMark(completion: { placemark, error in
            if let err = error {
                print(err.localizedDescription)
            } else if let p = placemark {
                self.parsePlacemark(placemark: p)
            }
        })
    }
    
    func parsePlacemark(placemark: CLPlacemark) {
        guard let location = placemark.location else { return }
        getWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        setLocationLabel(city: placemark.locality, state: placemark.administrativeArea)
    }
    
    func setLocationLabel(city: String?, state: String?) {
        if let city = city, let state = state {
            locationLabel.text = "\(city), \(state)"
        }
    }
    
    func getWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        DarkSkyWrapper.shared.getForcast(lat: latitude, long: longitude, completionHandler: { weatherArray, hourlyArray, error in
            if error != nil {
                print("Error: \(error!)")
            }
            if let weather = weatherArray {
                self.weatherArray = weather
                self.tableView.reloadData()
                self.displayCurrentConditions()
            }
            if let hourly = hourlyArray {
                self.hourlyWeather = hourly
                self.collectionView.reloadData()
            } else {
                print("hourlyWeather = nil")
            }
        })
    }
    
    func displayCurrentConditions() {
        if !weatherArray.isEmpty {
            
            if let currentTemp = weatherArray[0].currentTemp?.stringRepresentation {
                self.currentTempLabel.text = "\(currentTemp)°"
            }
            if let hi = weatherArray[0].highTemp.stringRepresentation {
                self.todayHiLabel.text = "\(hi)"
            }
            if let lo = weatherArray[0].lowTemp.stringRepresentation {
                self.todayLowLabel.text = "\(lo)"
            }
            self.currentSummaryLabel.text = weatherArray[0].summary
        }   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
