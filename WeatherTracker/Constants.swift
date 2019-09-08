//
//  Constants.swift
//  Tracker
//
//  Created by anshuman singh on 26/08/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation

struct Constants {
    
    static let agentDefaultName = NSLocalizedString("Weather Tracker", comment: "")
    
    struct MenuItemName {
        
        static let timeZone = NSLocalizedString("Time Zone", comment: "")
        static let settings = NSLocalizedString("Select your location on map", comment: "")
        static let refresh = NSLocalizedString("Refresh", comment: "")
        static let separator = "Separator"
        static let currentLocation = NSLocalizedString("Use Current Location", comment: "")
        static let quitApp = NSLocalizedString("Quit", comment: "")
        static let visibility = NSLocalizedString("Visibility", comment: "")
        
    }
    
    struct ErrorMessage {
        
        static let noDataAvailable = "Data not available..."
        static let nothingToParse = "No data to parse...parsing aborted"
        static let parseErrorOccured = "Parsing error occured with error:"
        static let badDataSource = "Bad data source"
        static let badURL = "Bad URL"
        static let noHourlyData = "No hourly data available"
        static let webServiceHandlerErrorNoAPIKey = "Can't initialize WebServiceHandler because API Key is nil"
        static let webServiceHandlerErrorNoBaseURL = "Can't initialize WebServiceHandler because base URL is nil"
    }
    
    struct StatusMessage {
        
        static let pleaseWait = NSLocalizedString("Loading...", comment: "")
        static let uiInitiated = "initializeUI called"
        static let noUpdateForUI = "Nothing to update in UI"
        static let noTimeZoneInfo = "No timezone info available"
    }
    
    struct AccessibilityStrings {
        
        static let refreshActionHint = NSLocalizedString("Refresh action will reload data", comment:"")
        static let settingActionHint = NSLocalizedString("This action will opne map view", comment:"")
        static let quitActionHint = NSLocalizedString("This action will quit the App", comment:"")
    }
    
    struct Location {
        
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
    struct UserCurrentLocation {
        
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
    struct StoryboardID {
        
        static let mapviewController = "mapviewcontroller"
    }
    
    struct Plist {
        
        static let infoPlist = "Info"
        static let configPlist = "Config"
        static let keyDataRefreshFrequency = "Data Refresh Frequency"
        static let baseURL = "BaseURL"
    }
    
}


extension NSNotification.Name {
    
    public static let currentLocationDidChangeNotification: NSNotification.Name = NSNotification.Name(rawValue: "CurrentLocationDidChangeNotification")

}
