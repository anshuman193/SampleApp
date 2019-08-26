//
//  Constants.swift
//  Tracker
//
//  Created by anshuman singh on 26/08/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation

struct Constants {
    
    struct ErrorMessage {
        static let kPleaseWait = "Please wait...we are fetching data"
    }
    
    struct StatusMessage {
        static let kPleaseWait = "Please wait...we are fetching data"
        static let kUIInitiated = "initializeUI called"
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

