//
//  LocationWrapper.swift
//  Outside Now
//
//  Created by Dave on 2/14/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationWrapper {
    
    static let shared = LocationWrapper()
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    var currentLocation: CLLocation?
    var authStatus = CLLocationManager.authorizationStatus()
   
    
    func canAccessLocation() -> Bool {
        switch authStatus {
            
        case .authorizedAlways:
            return true
        case .authorizedWhenInUse:
            return true
        case .denied:
            return false
        case .restricted:
            return false
        case .notDetermined:
           return false
        }
    }
    
    func requestAccess() {
        if authStatus == .denied {
            // We cannot ask the user again so we just want to alert them
            //
            if let topVC = UIApplication.topViewController() {
                topVC.showAlert(title: "Location Access Denied", message: "Without access to your location outside now can only provide weather if your search for a location. You can update location access in settings.")
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    func getPlaceMark(completion: @escaping(_ placemark: CLPlacemark?, _ error: Error?) ->()) {
        if self.authStatus == .authorizedWhenInUse || self.authStatus == .authorizedAlways {
            if let location = locationManager.location {
                self.currentLocation = location
                geoCoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let err = error {
                        completion(nil, err)
                    }
                    if let places = placemarks {
                        let placemarkArray = places as [CLPlacemark]
                        if !placemarkArray.isEmpty {
                            completion(placemarkArray[0], nil)
                        }
                    }
                }
            }
            else if let location = self.currentLocation {
                geoCoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let err = error {
                        completion(nil, err)
                    }
                    if let places = placemarks {
                        let placemarkArray = places as [CLPlacemark]
                        if !placemarkArray.isEmpty {
                            completion(placemarkArray[0], nil)
                        }
                    }
                }
            }
            else if let location = CLLocationManager().location {
                geoCoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let err = error {
                        completion(nil, err)
                    }
                    if let places = placemarks {
                        let placemarkArray = places as [CLPlacemark]
                        if !placemarkArray.isEmpty {
                            completion(placemarkArray[0], nil)
                        }
                    }
                }
            }
        } else {
            print("Auth status failed... in locationWrapper")
        }
    }
    
    func searchForPlacemark(text: String, completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
        geoCoder.geocodeAddressString(text, completionHandler: { (placemarks, error) in
            if let err = error {
                completion(nil, err)
            }
            if let places = placemarks {
                let placemarkArray = places as [CLPlacemark]
                if !placemarkArray.isEmpty {
                    completion(placemarkArray[0], nil)
                }
            }
        })
    }
}












































