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
        setupInStatusBar()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func setupInStatusBar(){
        statusItem.button?.title = "Fetching…"
        configMenuItems()
    }
    
    private func configMenuItems(){
        statusItem.menu = NSMenu()
        let separator = NSMenuItem(title: "Settings", action: #selector(showSettings), keyEquivalent: " ")
        statusItem.menu?.addItem(separator)
    }
    
    @objc func showSettings(){
        
    }

}

