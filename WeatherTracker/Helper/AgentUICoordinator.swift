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
    
    func refreshData()
    func refreshData(with location: CLLocation)
    func showMapInPopOver()
}


extension AgentUICoordinatorProtocol {
    
    func refreshData(with location: CLLocation) { Logger.debugLog("reload data with location") }
    func refreshData() { Logger.debugLog("reloadData") }
}

@objcMembers class AgentUICoordinator {
    
    weak var delegate: AgentUICoordinatorProtocol?
    
    private var weatherDataModel: WeatherData?
    
    private var timer: Timer?
    
    private var currentLocation: CLLocation? = nil
    
    private var blinkStatus: Bool = false
    
    private var usingCurrentLocation: Bool = false
    
    private let nc = NotificationCenter.default
    
    private let defaults = UserDefaults.standard
    
    private var menuItems: Array<String>? {
        
        didSet {
            updateMenuUI(menuItemsArray: menuItems)
        }
    }
    
    private var staticMenuItemsArray = [Constants.MenuItemName.separator,Constants.MenuItemName.refresh, Constants.MenuItemName.settings, Constants.MenuItemName.quitApp]
    
    var statusItem: NSStatusItem  = {
        
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.menu = NSMenu()
        return item
    }()
    
}


extension AgentUICoordinator: LocationManagerHelperProtocol {
    
    func currentLocationDidBecomeAvailable(locations: [CLLocation]) {
        
        extractAndSetMostRecentLocation(locationArray: locations)
    }
    
    private func extractAndSetMostRecentLocation(locationArray: [CLLocation]) {
        
        let lastItemIndex = locationArray.count - 1
        currentLocation = locationArray[lastItemIndex]
        
        guard let currLoc = currentLocation else { return }
        
        updateMenuAndRefreshData(with: currLoc)
    }
    
    private func updateMenuAndRefreshData(with currentloc: CLLocation) {
        
        staticMenuItemsArray = [Constants.MenuItemName.separator,Constants.MenuItemName.refresh, Constants.MenuItemName.settings, Constants.MenuItemName.currentLocation, Constants.MenuItemName.quitApp]
        
        delegate?.refreshData(with: currentloc)
    }
}

extension AgentUICoordinator {
    
    //MARK: Initail Setup
    
    func setup(withTitle name: String) {
        
        statusItem.button?.title = name
        statusItem.menu = NSMenu()
//        nc.addObserver(self, selector: #selector(handleCurrentLocationMenuItemSelection), name: .currentLocationDidBecomeAvailable, object:nil)

    }
    
    
    //MARK: Helpers
    
    func refreshMenuItems(model: WeatherData) {
        
        weatherDataModel = model
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
        
        menuItems = updateDynamicMenuItems(staticMenuItems: staticMenuItemsArray, data: modelData)
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
                
                title.append(" , \(Constants.MenuItemName.visibility) : \(visibility)")
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
            
        case Constants.MenuItemName.currentLocation:
            
            menuItem = NSMenuItem(title: item, action: #selector(handleCurrentLocationMenuItemSelection), keyEquivalent: "C")
//            menuItem.setAccessibilityHelp(Constants.AccessibilityStrings.quitActionHint)
            menuItem.target = self
            menuItem.state = usingCurrentLocation ? NSControl.StateValue.on : NSControl.StateValue.off
            break

            
        case Constants.MenuItemName.quitApp:
            
            menuItem = NSMenuItem(title: item, action: #selector(quitApp), keyEquivalent: "Q")
            menuItem.setAccessibilityHelp(Constants.AccessibilityStrings.quitActionHint)
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

    
    private func updateMenuUI(menuItemsArray: [String]?) {
        
        guard let menuItemsArr = menuItemsArray else {
            return
        }
        
        statusItem.menu?.removeAllItems()
        
        for item in menuItemsArr {
            
            let menuItem = prepareMenuItem(basedOn: item)
            statusItem.menu?.addItem(menuItem)
        }
    }
    
    //MARK: Menu click action
    
    @objc private func settings() {
        
        Logger.debugLog("Settings Menu Item selected")
        usingCurrentLocation = false
        delegate?.showMapInPopOver()
    }
    
    
    @objc private func refreshData() {
        
        delegate?.refreshData()
    }

    @objc private func handleCurrentLocationMenuItemSelection() {
        
        usingCurrentLocation.toggle()
        refreshData()
    }
    
    @objc private func quitApp() {
        
        exit(0)
    }
    
}

