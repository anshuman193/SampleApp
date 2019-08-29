//
//  Constants.swift
//  Tracker
//
//  Created by anshuman singh on 26/08/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation

struct Constants {
    
    static let kAgentDefaultName = "Tracker"
    
    struct MenuItemName {
        static let kSettings = "Select your location on map"
        static let kRefresh = "Refresh"
        static let kSeparator = "Separator"
        static let kCurrentLocation = "Use Current Location"
    }
    
    struct ErrorMessage {
        static let kNoDataAvailable = "Data not available..."
        static let kNothingToParse = "No data to parse...parsing aborted"
        static let kParseErrorOccured = "Parsing error occured with error:"
        static let kBadDataSource = "Bad data source"
        static let kBadURL = "Bad URL"
        static let kNoHourlyData = "No hourly data available"
    }
    
    struct StatusMessage {
        static let kPleaseWait = "Loading..."
        static let kUIInitiated = "initializeUI called"
        static let kNoUpdateForUI = "Nothing to update in UI"
        static let kNoTimeZoneInfo = "No timezone info available"
    }
    
    struct Location {
        static let kLatitude = "latitude"
        static let kLongitude = "longitude"
    }
    
    struct StoryboardID {
        static let kMapviewController = "mapviewcontroller"
    }
    
    struct Plist {
        static let kInfoPlist = "Info"
        static let kConfigPlist = "Config"
        static let kKeyAgentName = "Agent Name"
        static let kKeyDataRefreshFrequency = "Data Refresh Frequency"
        static let kBaseURL = "BaseURL"
        
        
    }
    
}

