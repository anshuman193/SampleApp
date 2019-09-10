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
    
    func currentLocationAvailablityDidSucceed(locations: [CLLocation])
    func currentLocationAvailablityDidFail()
}

class LocationManagerHelper: NSObject {

    weak var delegate: LocationManagerHelperProtocol?
    
    private var locationArray: [CLLocation]?
    
    private(set) var isUserCurrentLocationAvailable = false

    private let locationManager = CLLocationManager()
    
    private let defaults = UserDefaults.standard
    
    
    override init() {
        
        super.init()
        startGatheringUserLocationInfo()
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

extension LocationManagerHelper: CLLocationManagerDelegate {
    
    //MARK:CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        isUserCurrentLocationAvailable = true
        delegate?.currentLocationAvailablityDidSucceed(locations: locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        Logger.debugLog("locationManager didFailWithError \(error)")
        isUserCurrentLocationAvailable = false
        delegate?.currentLocationAvailablityDidFail()
    }

}
