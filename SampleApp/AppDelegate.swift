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

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        initializeAppUI()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func initializeAppUI(){
        statusItem.button?.title = agentName(plistname: "Info", and: "Agent Name")
        configMenuItems()
        Logger.debugLog("initializeAppUI")
    }
    
    private func configMenuItems(){
        statusItem.menu = NSMenu()
        let separator = NSMenuItem(title: "Settings", action: #selector(showSettings), keyEquivalent: " ")
        statusItem.menu?.addItem(separator)
    }
    
    @objc func showSettings(){
        
    }
    
    private func agentName(plistname name: String, and key : String) -> String {
        
        var agentName = "Tracker" // default value
        
        var dict: NSDictionary?
    
        if let path = Bundle.main.path(forResource: name, ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
        }
        
        if let name = dict?.value(forKey: key) as? String {
            
            agentName = name
        }
        
        return agentName
    
    }

}

