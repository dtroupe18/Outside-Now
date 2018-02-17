//
//  WeatherViewController.swift
//  Outside Now
//
//  Created by Dave on 2/14/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var currentSummaryLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var todayHiLabel: UILabel!
    @IBOutlet weak var todayLowLabel: UILabel!
    @IBOutlet weak var darkSkyButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var lastPlacemark: CLPlacemark?
    var lastTimestamp: Int64?
    
    var weatherArray = [Weather]()
    var hourlyWeather = [HourlyWeather]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewWillAppear....")
        if LocationWrapper.shared.canAccessLocation() {
            getPlacemark()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh notification
        //
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
        self.hideKeyboardWhenTappedAround()
        LocationWrapper.shared.locationManager.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        
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

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.backgroundColor = UIColor.black
        // Remove lines between tableview cells
        //
        tableView.separatorStyle = .none
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
        print("ViewDidAppear fired...")
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
        cell.imageView.image = DarkSkyWrapper.convertIconNameToImage(iconName: hourlyWeather[indexPath.row].iconName)
        return cell
    }
    
    // Marker: TableView Delegate
    //
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if weatherArray.isEmpty {
            return 0
        } else {
            // One extra row for the weekly summary
            //
            return weatherArray.count + 1
        }
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
                cell.selectionStyle = .none
            } else {
                cell.isHidden = true
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherCell
            // Remember the index here is +1 larger so we have to adjust to avoid an out of bounds exception
            //
            let index = indexPath.row - 1
            cell.weatherImageView.image = DarkSkyWrapper.convertIconNameToImage(iconName: weatherArray[index].iconName)
            cell.dayLabel.text = DarkSkyWrapper.convertTimestampToDayName(seconds: weatherArray[index].time)
            cell.hiLabel.text = weatherArray[index].highTemp.stringRepresentation
            cell.lowLabel.text = weatherArray[index].lowTemp.stringRepresentation
            cell.precipPercentLabel.text = weatherArray[index].precipProbability.percentString
            cell.backgroundColor = UIColor.black
            cell.dayLabel.textColor = UIColor.white
            cell.hiLabel.textColor = UIColor.white
            cell.lowLabel.textColor = UIColor.white
            cell.precipPercentLabel.textColor = UIColor.white
            cell.selectionStyle = .none
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
                if self.shouldRefreshWeather(placemark: p) {
                    CustomActivityIndicator.shared.showActivityIndicator(uiView: self.view)
                    self.parsePlacemark(placemark: p)
                } else {
                    // Do nothing
                    //
                   // print("Not refreshing weather")
                }
            }
        })
    }
    
    func shouldRefreshWeather(placemark: CLPlacemark) -> Bool {
        // If the placemark is new or enough time has passed (15 minutes) we can
        // refresh the weather data. This function also updates the value stored in
        // last placemark
        //
        if self.lastPlacemark == nil {
            // Save the last place we got the weather for
            //
            self.lastPlacemark = placemark
            self.lastTimestamp = Date().millisecondsSinceEpoch
            return true
        }
        else if fifteenMinutesSinceLastRequest() || isNewCity(placemark: placemark) {
            return true
        } else {
            return false
        }
    }
    
    func fifteenMinutesSinceLastRequest() -> Bool {
        // If we don't have a previous timestamp then just refresh
        //
        guard let oldMilliseconds = lastTimestamp else { return true }
        // Fifteen minutes in milliseconds
        //
        let minTimeDifference = (1000 * 60 * 15)
        if Date().millisecondsSinceEpoch - oldMilliseconds > minTimeDifference {
            return true
        } else {
            return false
        }
    }
    
    func isNewCity(placemark: CLPlacemark) -> Bool {
        guard let newCity = placemark.locality, let oldCity = lastPlacemark?.locality else { return false }
        if newCity != oldCity {
            return true
        } else {
            return false
        }
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
        DarkSkyWrapper.shared.getForecast(lat: latitude, long: longitude, completionHandler: { weatherArray, hourlyArray, error in
            
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
                self.collectionView.resetScrollPositionToTop()
                self.collectionView.reloadData()
            } else {
                print("hourlyWeather = nil")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
            }
        })
    }
    
    func displayCurrentConditions() {
        if !weatherArray.isEmpty {
            
            let alert = DarkSkyWrapper.shared.getAlerts()
            if alert != "" {
                alertLabel.text = alert
            }
            
            if let currentTemp = weatherArray[0].currentTemp?.stringRepresentation {
                currentTempLabel.text = "\(currentTemp)°"
            }
            if let hi = weatherArray[0].highTemp.stringRepresentation {
                todayHiLabel.text = "\(hi)"
            }
            if let lo = weatherArray[0].lowTemp.stringRepresentation {
                todayLowLabel.text = "\(lo)"
            }
            currentSummaryLabel.text = weatherArray[0].summary
        }   
    }
    
    // Marker: TextView Delegate
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let text = textField.text else { return true }
        LocationWrapper.shared.searchForPlacemark(text: text, completion: { placemark, error in
            if let err = error {
                print(err.localizedDescription)
            }
            if let p = placemark {
                self.parsePlacemark(placemark: p)
            }
        })
        return true
    }
    
    @IBAction func darkSkyButtonPressed(_ sender: Any) {
        // The use of Dark Sky's API requires that they receive credit and a link to https://darksky.net/poweredby/
        // be placed in the app
        //
        if let url = URL(string: "https://darksky.net/poweredby/") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func applicationWillEnterForeground() {
        print("Application will enter foreground fired...")
        getPlacemark()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        // Remove the noticiation
        //
        NotificationCenter.default.removeObserver(self)
    }
}
