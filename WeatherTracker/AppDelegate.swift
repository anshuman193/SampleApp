//
//  AppDelegate.swift
//  WeatherTracker
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
        
        let interval = Utility.refreshInterval(plistname: Constants.Plist.configPlist, and: Constants.Plist.keyDataRefreshFrequency)
        mapVC.startLoadingData(withTimeInterval: interval)
    }
    
    private func initializeAppUI() {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let mapVC = storyboard.instantiateController(withIdentifier: Constants.StoryboardID.mapviewController)
            as? MapViewController else  {

            Logger.debugLog("Could not initialize MapViewCOntroller")
            return
        }

        mapVC.setup()
        loadData(mapVC)
    }
}

