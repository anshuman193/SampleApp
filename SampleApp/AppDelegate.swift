//
//  AppDelegate.swift
//  SampleApp
//
//  Created by Anshuman Singh on 8/23/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        initializeAppUI()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    fileprivate func initializeAppUI(){
        
        let agent = agentName(plistname: "Config", and: "Agent Name")
        let interval = refreshInterval(plistname: "Config", and: "Data Refresh Frequency")
        AgentUICoordinator.shared.setup(withTitle: agent)
        AgentUICoordinator.shared.configMenuItems()
        let mapVC = MapViewController()
        mapVC.startLoadingData(withTimeInterval: interval)
        
    }
    
    fileprivate func agentName(plistname name: String, and key : String) -> String {
        
        var agentName = "Tracker" // default value
        if let value = Utility.readValue(fromplistFile: "Config" , forKey: key) {
            agentName = value
        }
        return agentName
    }
    
    fileprivate func refreshInterval(plistname name: String, and key : String) -> Int {
        
        var interval = 300 // default value in seconds
        if let value = Utility.readValue(fromplistFile: "Config" , forKey: key), let refreshInterval = Int(value) {
            interval = refreshInterval
        }
        return interval
    }
}

