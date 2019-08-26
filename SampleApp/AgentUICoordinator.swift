//
//  UIManager.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/24/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation
import AppKit
import MapKit

@objcMembers class AgentUICoordinator {
    
    static let shared = AgentUICoordinator()
    fileprivate var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    fileprivate let settingMenuItem = NSMenuItem(title: "Settings", action: #selector(settings), keyEquivalent: " ")
    fileprivate init(){}
    fileprivate var dataModelArr: [CurrentWeatherInfo]?
    fileprivate var timer: Timer?
    fileprivate var blinkStatus: Bool = false

}

extension AgentUICoordinator {
    
    func setup(withTitle name: String) {
        
        statusItem.button?.title = name
        Logger.debugLog("initializeUI called")
    }
    
    func refreshMenuItems(modelArr: [CurrentWeatherInfo?]) {

        updateSubmenuItems(modelArray: modelArr)
    }
    
    func configMenuItems() {

        statusItem.menu = NSMenu()
        settingMenuItem.target = self
        statusItem.menu?.addItem(settingMenuItem)
    }

    @objc fileprivate func settings(){

        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: Constants.StoryboardID.kMapviewController) as? NSViewController else { return }
        makePopOver(vc: vc, uiElement: statusItem)
    }

    
    func makePopOver(vc: NSViewController, uiElement: NSStatusItem) -> Void {
        let popOverView = constructPopOver(vc)
        displayPopOver(popOverView, uiElement: self.statusItem)
        Logger.debugLog("makePopOver called")
    }
    
    //MARK: helper methods


    func startTextAnimator(){
        timer = Timer.scheduledTimer(timeInterval:1.0, target: self, selector: #selector(self.blink), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    fileprivate func getAgentName() -> String {
        
        var agentName = "Tracker"
        if let value = Utility.readValue(fromplistFile: Constants.Plist.kConfigPlist , forKey: Constants.Plist.kKeyAgentName) {
            agentName = value
        }
        
        return agentName
    }
    
    func stopTextAnimator(){
        
        timer?.invalidate()
        self.statusItem.button?.title = getAgentName()
    }
    
    @objc fileprivate func blink() {

        let agentName = getAgentName()
        
        if blinkStatus {
            blinkStatus = false
            self.statusItem.button?.title = agentName
        } else {
            blinkStatus = true
            self.statusItem.button?.title = Constants.StatusMessage.kPleaseWait
        }
    }

    
    fileprivate func displayPopOver(_ popOverView: NSPopover, uiElement: NSStatusItem) {
        popOverView.show(relativeTo: uiElement.button!.bounds, of: uiElement.button!, preferredEdge: .maxY)
    }
    
    fileprivate func closePopOver(_ popOverView: NSPopover) {
        popOverView.close()
    }
    
    fileprivate func constructPopOver(_ vc: NSViewController?) -> NSPopover {
        let popOverView =  NSPopover()
        popOverView.contentViewController = vc
        popOverView.behavior = .transient
        return popOverView
    }
    
    fileprivate func updateSubmenuItems(modelArray: [CurrentWeatherInfo?]) {
        
        statusItem.menu?.removeAllItems()
        
        for model in modelArray {
            
            guard let dataModel = model else {return}
            
            var title = Constants.ErrorMessage.kNoDataAvailable
            
            if let time = dataModel.time {
                
                let date = Date(timeIntervalSince1970: time)
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                let formattedDate = formatter.string(from: date)
                title = (formattedDate)
            }

            if let summary = dataModel.summary {
                title.append(": \(summary)")
            }
            
            if let temperature = dataModel.temperature {
                title.append(" \(temperature)°F")
            }

            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            menuItem.isEnabled = false
            statusItem.menu?.addItem(menuItem)
        }
        
        statusItem.menu?.addItem(settingMenuItem)
        
    }

}

