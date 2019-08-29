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

protocol AgentUICoordinatorProtocol: class {
    
    func reloadData()
}

extension AgentUICoordinatorProtocol {
    
    func reloadData() { Logger.debugLog("reloadData") }
}

@objcMembers class AgentUICoordinator {
    
    static let shared = AgentUICoordinator()
    weak var delegate: AgentUICoordinatorProtocol?
    fileprivate var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    fileprivate let settingMenuItem = NSMenuItem(title: "Settings", action: #selector(settings), keyEquivalent: " ")
    fileprivate var dataModelArr: [HourlyWeatherDataDetails]?
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
    
    func refreshMenuItems(model: WeatherData) {

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
        
       self.delegate?.reloadData()
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
    
    
    fileprivate func updateUI(modelData: WeatherData){
        
        let menuItems = updateDynamicMenuItems(staticMenuItems: staticMenuItemsArray, data: modelData)
        updateMenuUI(menuItemsArray: menuItems)
    }
    
    
    fileprivate func addTimeZone(_ data: WeatherData, _ dynamicMenuItemsArray: inout [String]) {
        
        if let timeZoneInfo = data.timezone {
            
            dynamicMenuItemsArray.append(timeZoneInfo)
            dynamicMenuItemsArray.append(Constants.MenuItemName.kSeparator)
        } else {
            
            Logger.debugLog(Constants.StatusMessage.kNoTimeZoneInfo)
        }
    }
    
    fileprivate func updateDynamicMenuItems(staticMenuItems: Array<String>, data: WeatherData) -> Array<String> {
        
        var title = Constants.ErrorMessage.kNoDataAvailable
        var dynamicMenuItemsArray = [String]()
        
        addTimeZone(data, &dynamicMenuItemsArray)
        
        title = Constants.ErrorMessage.kNoDataAvailable
        
        guard let hourlyData = data.hourly else {
            
            Logger.debugLog(Constants.ErrorMessage.kNoHourlyData)
            return staticMenuItems
        }
        
        for hourlyData in hourlyData.hourlyDetailsArray.prefix(12) {
            
            if let time = hourlyData?.time {
                
                let date = Date(timeIntervalSince1970: TimeInterval(time))
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                let formattedDate = formatter.string(from: date)
                title = (formattedDate)
            }
            
            if let summary = hourlyData?.summary {
                
                title.append(": \(summary)")
            }
            
            if let temperature = hourlyData?.temperature {
                
                title.append(" \(temperature)°F")
            }
            
            if let visibility = hourlyData?.visibility {
                
                title.append(" | Visibility: \(visibility)")
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

