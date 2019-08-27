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
    
    struct ErrorMessage {
        static let kNoDataAvailable = "Data not available..."
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

