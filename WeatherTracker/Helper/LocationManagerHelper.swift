//
//  LocationManagerHelper.swift
//  Weather Tracker
//
//  Created by Anshuman Singh on 9/7/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManagerHelper: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    private let defaults = UserDefaults.standard
    
    private var userCurrentCoordinates: (latitude: Double, longitude: Double) {
        
        let latitude = defaults.double(forKey: Constants.UserCurrentLocation.latitude)
        let longitude = defaults.double(forKey: Constants.UserCurrentLocation.longitude)
        return (latitude, longitude)
    }

    
    override init() {
        
        super.init()
        startGatheringUserLocationInfo()
    }
    
    
    //MARK:CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        defaults.set(locValue.latitude, forKey: Constants.UserCurrentLocation.latitude)
        defaults.set(locValue.longitude, forKey: Constants.UserCurrentLocation.longitude)
        Logger.debugLog("Current location = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        Logger.debugLog("locationManager didFailWithError \(error)")
    }
    
    
    //MARK: Helpers
    
    
    private func startGatheringUserLocationInfo() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        
        printLocationAuthorizationStatus()
    }
    
    fileprivate func printLocationAuthorizationStatus() {
        
        Logger.debugLog("location manager auth status changed to: " )
        
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedAlways:
            Logger.debugLog("authorized always")
            break
            
        case .denied:
            Logger.debugLog("denied")
            break
            
        case .notDetermined:
            Logger.debugLog("not yet determined")
            break
            
        case .restricted:
            Logger.debugLog("restricted")
            break
            
        default:
            Logger.debugLog("Unknown")
        }
    }

}
