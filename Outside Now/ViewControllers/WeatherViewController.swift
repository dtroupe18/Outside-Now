//
//  WeatherViewController.swift
//  Outside Now
//
//  Created by Dave on 2/14/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var currentSummaryLabel: UILabel!
    @IBOutlet weak var todayHiLabel: UILabel!
    @IBOutlet weak var todayLowLabel: UILabel!
    @IBOutlet weak var darkSkyButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    
    var lastPlacemark: CLPlacemark?
    
    // Flag used to determine when you refresh the weather data
    //
    var lastTimestamp: Int64?
    
    // Save the timezone so the timestamps can be converted to their local time
    // if the user searches for a location in another timeZone.
    //
    var requestTimeZone: String?
    
    var weatherArray = [Weather]()
    var hourlyWeather = [HourlyWeather]()
    
    var selectedIndex: Int = -1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
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
        searchbar.delegate = self
        
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = UIScreen.main.bounds.width
            let height = collectionView.bounds.height
            flow.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flow.minimumInteritemSpacing = 0
            flow.minimumLineSpacing = 0
            flow.itemSize = CGSize(width: width / 5, height: height)
        }
        
        // SearchBar text color
        //
        let textFieldInsideSearchBar = searchbar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        collectionView.layer.borderWidth = 1
        collectionView.layer.cornerRadius = 8
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
                showAlert(title: "Location Access Denied", message: "Without access to your location Outside Now can only provide weather if your search for a location. You can update location access in settings.")
            }
        }
    }
    
    // Marker: CLLocationManagerDelegate
    //
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        LocationWrapper.shared.authStatus = status
        if status == .denied {
            showAlert(title: "Location Access Denied", message: "Without access to your location Outside Now can only provide weather if your search for a location. You can update location access in settings.")
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
        cell.hourLabel.text = DarkSkyWrapper.convertTimestampToHour(seconds: hourlyWeather[indexPath.row].time, timeZone: lastPlacemark?.timeZone)
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
            return weatherArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Show the weekly summary cell
            //
            let cell = tableView.dequeueReusableCell(withIdentifier: "weeklySummaryCell", for: indexPath) as! WeeklySummaryCell
            
            if let summary = DarkSkyWrapper.shared.getWeeklySummary() {
                cell.weeklySummaryLabel.textColor = UIColor.white
                cell.summaryLabel.text = summary
                cell.summaryLabel.textColor = UIColor.white
                // Double use for this cell
                // It can display the weekly summary or the local weather alert
                //
                let alert = DarkSkyWrapper.shared.getAlerts()
                if alert != "" {
                    cell.summaryLabel.text = alert
                    cell.weeklySummaryLabel.text = "Weather Alert"
                    cell.summaryLabel.textColor = UIColor.red
                    cell.weeklySummaryLabel.textColor = UIColor.red
                }
                cell.backgroundColor = UIColor.black
                cell.selectionStyle = .none
            } else {
                cell.isHidden = true
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherCell
            // Skip index 0 which is the current days weather since it is already displayed
            //
            let index = indexPath.row
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Segue to that days weather
        //
        if indexPath.row != 0 && lastPlacemark != nil {
            // Subtract one becuase the tableview has a summary row at index 0
            //
            selectedIndex = indexPath.row
            self.performSegue(withIdentifier: "toDailyWeather", sender: nil)
        }
    }
    
    // Marker: Location - Weather
    //
    func getPlacemark() {
        LocationWrapper.shared.getPlaceMark(completion: { placemark, error in
            if let err = error {
                self.showAlert(title: "Error", message: err.localizedDescription)
            } else if let p = placemark {
                if self.shouldRefreshWeather(placemark: p) {
                    // Update the timestamp everytime the weather is refreshed
                    //
                    self.lastTimestamp = Date().millisecondsSinceEpoch
                    CustomActivityIndicator.shared.showActivityIndicator(uiView: self.view)
                    self.parsePlacemark(placemark: p)
                } else {
                    // Do nothing
                    //
                }
            }
        })
    }
    
    func shouldRefreshWeather(placemark: CLPlacemark) -> Bool {
        // If enough time has passed (15 minutes) we refresh the weather data.
        //
        if self.lastPlacemark == nil {
            // Initial request
            //
            return true
            // User could have changed their location before 15 minutes have passed
            //
        } else if fifteenMinutesSinceLastRequest() {
            return true
        } else {
            return false
        }
        // Note that searches are run checked with this function they always
        // result in a new weather request
        //
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
    
    // Not being used
    //
    func isNewCity(placemark: CLPlacemark) -> Bool {
        guard let newCity = placemark.locality, let oldCity = lastPlacemark?.locality else { return true }
        if newCity == oldCity {
            return false
        } else {
            return true
        }
    }
    
    func parsePlacemark(placemark: CLPlacemark) {
        guard let location = placemark.location else { return }
        // Update lastPlacemark everytime a new one is parsed
        //
        self.lastPlacemark = placemark
        getWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        setLocationLabel(placemark: placemark)
        
    }
    
    func setLocationLabel(placemark: CLPlacemark) {
        let city = placemark.locality
        let state = placemark.administrativeArea
        let country = placemark.country
        
        if city != nil && state != nil {
            locationLabel.text = "\(city!), \(state!)"
        } else if city != nil && country != nil {
            locationLabel.text = "\(city!), \(country!)"
        } else if state != nil && country != nil {
            locationLabel.text = "\(state!), \(country!)"
        } else if city != nil {
            locationLabel.text = "\(city!)"
        } else if state != nil {
            locationLabel.text = "\(state!)"
        } else if country != nil {
            locationLabel.text = "\(country!)"
        } else {
            // Stranger Things Easter Egg
            //
            locationLabel.text = "Hawkins, IN"
        }
    }
    
    func getWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        DarkSkyWrapper.shared.getForecast(lat: latitude, long: longitude, completionHandler: { weatherArray, hourlyArray, error in
            
            if error != nil {
                self.showAlert(title: "Error", message: error!.localizedDescription)
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
            }
        })
    }
    
    func displayCurrentConditions() {
        if !weatherArray.isEmpty {
            let attribute = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17)]
            
            if let currentTemp = weatherArray[0].currentTemp?.stringRepresentation {
                currentTempLabel.text = "\(currentTemp)°"
            }
            
            if let hi = weatherArray[0].highTemp.stringRepresentation {
                let attributedHi = NSMutableAttributedString(string:  "High  ", attributes: attribute)
                let attributedHiTemp = NSMutableAttributedString(string: "\(hi)°")
                attributedHi.append(attributedHiTemp)

                todayHiLabel.attributedText = attributedHi
            }
            if let lo = weatherArray[0].lowTemp.stringRepresentation {
                let attributedLow = NSMutableAttributedString(string: "Low   ", attributes: attribute)
                let attributedLowTemp = NSMutableAttributedString(string: "\(lo)°")
                attributedLow.append(attributedLowTemp)
                
                todayLowLabel.attributedText = attributedLow
            }
            currentSummaryLabel.text = weatherArray[0].summary
        }   
    }
    
    // Marker: SearchBar Delegate
    //
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        CustomActivityIndicator.shared.showActivityIndicator(uiView: self.view)
        searchbar.resignFirstResponder()
        guard let text = searchbar.text else { return }
        searchbar.text = ""
        LocationWrapper.shared.searchForPlacemark(text: text, completion: { placemark, error in
            if let err = error {
                CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                self.showAlert(title: "Error", message: err.localizedDescription)
            }
            if let p = placemark {
                self.parsePlacemark(placemark: p)
            }
        })
    }
    
    
    @IBAction func notificationButtonPressed(_ sender: Any) {
        // Go to notifications VC
        //
        self.performSegue(withIdentifier: "toNotifications", sender: nil)
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
        getPlacemark()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDailyWeather" {
            if let vc = segue.destination as? DayViewController {
                vc.locationString = locationLabel.text
                if selectedIndex != -1 {
                    vc.weatherArray = weatherArray
                    vc.currentIndex = selectedIndex
                }
                if let placemark = lastPlacemark {
                    vc.placemark = placemark
                }
            }
        }
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
