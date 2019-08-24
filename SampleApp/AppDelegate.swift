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
    let uiHandler = UIHandler<NSStatusItem>()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        initializeAppUI()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func initializeAppUI(){
        uiHandler.setup(uiElement: statusItem)
        configMenuItems()
    }
    
    private func configMenuItems(){
        statusItem.menu = NSMenu()
        let settingMenuItem = NSMenuItem(title: "Settings", action: #selector(settings), keyEquivalent: " ")
        statusItem.menu?.addItem(settingMenuItem)
    }
    
    @objc private func settings(){
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "viewcontroller1") as? ViewController else { return }
        uiHandler.makePopOver(vc: vc, uiElement: statusItem)
    }
    
}

