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
    
    private(set) var isUserCurrentLocationAvailable: Bool = false {
        
        didSet {
            notifyForCurrLocation()
        }
    }
    
    private let locationManager = CLLocationManager()
    
    private let defaults = UserDefaults.standard
    
    
    override init() {
        
        super.init()
        startGatheringUserLocationInfo()
    }
    
    
    //MARK:CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        defaults.set(locValue.latitude, forKey: Constants.UserCurrentLocation.latitude)
//        defaults.set(locValue.longitude, forKey: Constants.UserCurrentLocation.longitude)
//        Logger.debugLog("Current location = \(locValue.latitude) \(locValue.longitude)")
        
        for loc in locations {
            
            Logger.debugLog("lat \(loc.coordinate.latitude)")
            Logger.debugLog("long \(loc.coordinate.longitude)")
        }
        
        isUserCurrentLocationAvailable = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        Logger.debugLog("locationManager didFailWithError \(error)")
        isUserCurrentLocationAvailable = false
    }
    
    
    //MARK: Helpers
    
    private func notifyForCurrLocation() {
        
        if isUserCurrentLocationAvailable {
            
            NotificationCenter.default.post(name: .currentLocationDidBecomeAvailable, object: isUserCurrentLocationAvailable)
        }
    }
    
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
