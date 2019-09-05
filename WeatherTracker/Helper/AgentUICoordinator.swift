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
    func showMapInPopOver()
}


extension AgentUICoordinatorProtocol {
    
    func reloadData() { Logger.debugLog("reloadData") }
}

@objcMembers class AgentUICoordinator {
    
    weak var delegate: AgentUICoordinatorProtocol?
    
    private var timer: Timer?
    
    private var blinkStatus: Bool = false
    
    private var staticMenuItemsArray = [Constants.MenuItemName.separator,Constants.MenuItemName.refresh, Constants.MenuItemName.settings, Constants.MenuItemName.currentLocation]
    
    var statusItem: NSStatusItem  = {
        
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.menu = NSMenu()
        return item
    }()
    
}

extension AgentUICoordinator {
    
    //MARK: Initail Setup
    
    func setup(withTitle name: String) {
        
        statusItem.button?.title = name
            configMenuItems()
    }
    
    private func configMenuItems() {

        statusItem.menu = NSMenu()
        updateMenuUI(menuItemsArray: staticMenuItemsArray)
    }
    
    
    //MARK: Helpers
    
    func refreshMenuItems(model: WeatherData) {
        
        updateUI(modelData: model)
    }

    func startTextAnimator() {
        
        timer = Timer.scheduledTimer(timeInterval:1.0, target: self, selector: #selector(blink), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func stopTextAnimator() {
        
        timer?.invalidate()
        let str = Constants.agentDefaultName
        statusItem.button?.title = str
    }
    
    @objc private func blink() {

        statusItem.button?.title = blinkStatus ? Constants.agentDefaultName : Constants.StatusMessage.pleaseWait
        blinkStatus.toggle()
    }

    
    private func updateUI(modelData: WeatherData) {
        
        let menuItems = updateDynamicMenuItems(staticMenuItems: staticMenuItemsArray, data: modelData)
        updateMenuUI(menuItemsArray: menuItems)
    }
    
    
    private func addTimeZone(_ data: WeatherData, _ dynamicMenuItemsArray: inout [String]) {
        
        if let timeZoneInfo = data.timezone {
            
            dynamicMenuItemsArray.append(Constants.MenuItemName.timeZone + ": " + "\(timeZoneInfo)") 
            dynamicMenuItemsArray.append(Constants.MenuItemName.separator)
        } else {
            
            Logger.debugLog(Constants.StatusMessage.noTimeZoneInfo)
        }
    }
    
    private func updateDynamicMenuItems(staticMenuItems: Array<String>, data: WeatherData) -> Array<String> {
        
        var title = Constants.ErrorMessage.noDataAvailable
        var dynamicMenuItemsArray = [String]()
        
        addTimeZone(data, &dynamicMenuItemsArray)
        
        title = Constants.ErrorMessage.noDataAvailable
        
        guard let hourlyData = data.hourly else {
            
            Logger.debugLog(Constants.ErrorMessage.noHourlyData)
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
                
                title.append(" | \(Constants.MenuItemName.visibility) : \(visibility)")
            }
            

            dynamicMenuItemsArray.append(title)
        }

        let finalArray = dynamicMenuItemsArray + staticMenuItems
        return finalArray
    }
    
    
    private func prepareMenuItem(basedOn item: String) -> NSMenuItem {
        
        var menuItem: NSMenuItem
        
        switch item {
            
        case Constants.MenuItemName.settings:
            
            menuItem = NSMenuItem(title: item, action: #selector(settings), keyEquivalent: "S")
            menuItem.setAccessibilityHelp(Constants.AccessibilityStrings.settingActionHint)
            menuItem.target = self
            break
            
        case Constants.MenuItemName.refresh:
            
            menuItem = NSMenuItem(title: item, action: #selector(refreshData), keyEquivalent: "R")
            menuItem.setAccessibilityHelp(Constants.AccessibilityStrings.refreshActionHint)
            menuItem.target = self
            break
            
        case Constants.MenuItemName.separator:
            
            menuItem = NSMenuItem.separator()
            break
            
        default:
            
            menuItem = NSMenuItem(title: item, action: nil, keyEquivalent: "")
            menuItem.isEnabled = false
            
        }
        return menuItem
    }

    
    private func updateMenuUI(menuItemsArray: [String]) {
        
        statusItem.menu?.removeAllItems()
        
        for item in menuItemsArray {
            
            let menuItem = prepareMenuItem(basedOn: item)
            statusItem.menu?.addItem(menuItem)
        }
    }
    
    //MARK: Menu click action
    
    @objc private func settings() {
        
        Logger.debugLog("Settings Menu Item selected")
        delegate?.showMapInPopOver()
    }
    
    
    @objc private func refreshData() {
        
        delegate?.reloadData()
    }

}

