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
    fileprivate var dataModelArr: [CurrentWeatherInfo]?
    fileprivate var timer: Timer?
//    fileprivate var popover: NSPopover
    fileprivate var blinkStatus: Bool = false
    fileprivate var staticMenuItemsArray = [Constants.MenuItemName.kSeparator,Constants.MenuItemName.kRefresh, Constants.MenuItemName.kSettings, Constants.MenuItemName.kCurrentLocation]
    
    fileprivate init(){}

}

extension AgentUICoordinator {
    
    func setup(withTitle name: String) {
        
        statusItem.button?.title = name
        Logger.debugLog("initializeUI called")
    }
    
    func refreshMenuItems(model: HourlyWeatherData?) {

        updateUI(modelData: model)
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
    
    @objc fileprivate func refreshData() {
        
        Logger.debugLog("refreshData")

    }

    func dismissPopOver() {
        
    }
    
    func makePopOver(vc: NSViewController, uiElement: NSStatusItem) -> Void {
        
        let popover = constructPopOver(vc)
        displayPopOver(popover, uiElement: self.statusItem)
        
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
    
    
    fileprivate func updateUI(modelData: HourlyWeatherData?){
        
        let menuItems = updateDynamicMenuItems(staticMenuItems: staticMenuItemsArray, data: modelData)
        updateMenuUI(menuItemsArray: menuItems)
    }
    
    
    fileprivate func addTimeZone(_ data: HourlyWeatherData?, _ dynamicMenuItemsArray: inout [String]) {
        
        if let timeZoneInfo = data?.timeZone {
            
            dynamicMenuItemsArray.append(timeZoneInfo)
            dynamicMenuItemsArray.append(Constants.MenuItemName.kSeparator)
        } else {
            
            Logger.debugLog(Constants.StatusMessage.kNoTimeZoneInfo)
        }
    }
    
    fileprivate func updateDynamicMenuItems(staticMenuItems: Array<String>, data: HourlyWeatherData?) -> Array<String> {
        
        var title = Constants.ErrorMessage.kNoDataAvailable
        var dynamicMenuItemsArray = [String]()
        
        guard let modelArray = data?.dataArray else {
            
            Logger.debugLog(Constants.StatusMessage.kNoUpdateForUI)
            return staticMenuItems
        }
        
        addTimeZone(data, &dynamicMenuItemsArray)
        
        for model in modelArray {

            guard let dataModel = model else {return staticMenuItems}
            
            title = Constants.ErrorMessage.kNoDataAvailable

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

            dynamicMenuItemsArray.append(title)
        }
        
        let finalArray = dynamicMenuItemsArray + staticMenuItems
        return finalArray
    }
    
    
    fileprivate func prepareMenuItem(basedOn item: String) -> NSMenuItem {
        
        var menuItem: NSMenuItem
        
        switch item {
            
        case Constants.MenuItemName.kSettings:
            
            menuItem = NSMenuItem(title: item, action: #selector(settings), keyEquivalent: "S")
            menuItem.target = self
            break
            
        case Constants.MenuItemName.kRefresh:
            
            menuItem = NSMenuItem(title: item, action: #selector(refreshData), keyEquivalent: "R")
            menuItem.target = self
            break
            
        case Constants.MenuItemName.kSeparator:
            
            menuItem = NSMenuItem.separator()
            break
            
        default:
            
            menuItem = NSMenuItem(title: item, action: nil, keyEquivalent: "")
            menuItem.isEnabled = false
            
        }
        
        return menuItem
    }
    
    fileprivate func updateMenuUI(menuItemsArray: [String]) {
        
        statusItem.menu?.removeAllItems()
        
        for item in menuItemsArray {
            
            let menuItem = prepareMenuItem(basedOn: item)
            statusItem.menu?.addItem(menuItem)
        }
    }
    

}

