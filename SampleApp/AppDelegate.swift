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

    private func initializeAppUI(){
        
        let agent = agentName(plistname: "Info", and: "Agent Name")
        AgentUICoordinator.shared.setup(withTitle: agent)
        AgentUICoordinator.shared.configMenuItems()
    }
    
    private func agentName(plistname name: String, and key : String) -> String {
        
        var agentName = "Tracker" // default value
        
        if let value = Utility.readValue(fromplistFile: "Config" , forKey: key) {
            agentName = value
        }
        
        return agentName
    }
}

