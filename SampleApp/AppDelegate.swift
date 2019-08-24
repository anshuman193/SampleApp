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
        let separator = NSMenuItem(title: "Settings", action: #selector(settings), keyEquivalent: " ")
        statusItem.menu?.addItem(separator)
    }
    
    fileprivate func displayPopOver(_ popOverView: NSPopover) {
        popOverView.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
    }
    
    fileprivate func closePopOver(_ popOverView: NSPopover) {
        popOverView.close()
    }
    
    fileprivate func constructPopOver(_ vc: ViewController) -> NSPopover {
        let popOverView =  NSPopover()
        popOverView.contentViewController = vc
        popOverView.behavior = .transient
        return popOverView
    }
    
    @objc func settings(){
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "viewcontroller1") as? ViewController else { return }
        
        let popOverView = constructPopOver(vc)
        displayPopOver(popOverView)
        
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

