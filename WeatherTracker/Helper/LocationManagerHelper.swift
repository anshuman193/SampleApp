//
//  LocationManagerHelper.swift
//  Weather Tracker
//
//  Created by Anshuman Singh on 9/7/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerHelperProtocol:  class {
    
    func currentLocationDidBecomeAvailable(locations: [CLLocation])
}

class LocationManagerHelper: NSObject, CLLocationManagerDelegate {

    weak var delegate: LocationManagerHelperProtocol?
    
    private var locationArray: [CLLocation]?
    
    private(set) var isUserCurrentLocationAvailable = false

    private let locationManager = CLLocationManager()
    
    private let defaults = UserDefaults.standard
    
    
    override init() {
        
        super.init()
        startGatheringUserLocationInfo()
    }
    
    
    //MARK:CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationArray = locations
        isUserCurrentLocationAvailable = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        Logger.debugLog("locationManager didFailWithError \(error)")
        isUserCurrentLocationAvailable = false
    }
    
    
    //MARK: Helpers
    
    private func notifyForCurrLocation() {

        guard let locArr = locationArray else {
            
            return
        }
        
        if isUserCurrentLocationAvailable {
            
            delegate?.currentLocationDidBecomeAvailable(locations: locArr)
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
