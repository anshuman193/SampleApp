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

    private func loadData(_ mapVC: MapViewController) {
        
        let interval = Utility.refreshInterval(plistname: Constants.Plist.kConfigPlist, and: Constants.Plist.kKeyDataRefreshFrequency)
        mapVC.startLoadingData(withTimeInterval: interval)
    }
    
    private func initializeController() {
        
        let mapVC = MapViewController()
        AgentUICoordinator.shared.delegate = mapVC
        loadData(mapVC)
    }
    
    private func initializeAppUI(){
        
        let agent = Utility.agentName(plistname: Constants.Plist.kConfigPlist, and: Constants.Plist.kKeyAgentName)
        AgentUICoordinator.shared.setup(withTitle: agent)
        AgentUICoordinator.shared.configMenuItems()
        initializeController()
    }


}

