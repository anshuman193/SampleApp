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

@objcMembers class AgentUICoordinator: MapViewObserver {
    
    static let shared = AgentUICoordinator()
    weak var delegate: AgentUICoordinatorProtocol?
    private var popOverView: NSPopover
    private var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let settingMenuItem = NSMenuItem(title: "Settings", action: #selector(settings), keyEquivalent: " ")
    private var timer: Timer?
    private var blinkStatus: Bool = false
    private var staticMenuItemsArray = [Constants.MenuItemName.separator,Constants.MenuItemName.refresh, Constants.MenuItemName.settings, Constants.MenuItemName.currentLocation]
    
    private init() {
        
        popOverView = NSPopover()
    }
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

    @objc private func settings() {

        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: Constants.StoryboardID.mapviewController) as? NSViewController else { return }
        makePopOver(vc: vc, uiElement: statusItem)
    }
    
    @objc private func refreshData() {
        
       self.delegate?.reloadData()
    }

    
    func makePopOver(vc: NSViewController, uiElement: NSStatusItem) -> Void {
        
        preparePopOver(with: vc)
        displayPopOver(relativeTo: self.statusItem)
    }
    
    
    //MARK: MapViewObserver
    
    func doneButtonClicked() {
        
        closePopOver()
    }
    
    //MARK: helper methods


    func startTextAnimator(){
        timer = Timer.scheduledTimer(timeInterval:1.0, target: self, selector: #selector(self.blink), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
//    private func getAgentName() -> String {
//        
//        var agentName = "Tracker"
//        if let value = Utility.readValue(fromplistFile: Constants.Plist.configPlist , forKey: Constants.Plist.keyAgentName) {
//            agentName = value
//        }
//        
//        return agentName
//    }
    
    func stopTextAnimator(){
        
        timer?.invalidate()
        let str = Constants.agentDefaultName
        self.statusItem.button?.title = str
    }
    
    @objc private func blink() {

        if blinkStatus {

            self.statusItem.button?.title = Constants.agentDefaultName
        } else {

            self.statusItem.button?.title = Constants.StatusMessage.pleaseWait
        }
        
        blinkStatus.toggle()
    }

    
    private func displayPopOver(relativeTo uiElement: NSStatusItem) {
        
        popOverView.show(relativeTo: uiElement.button!.bounds, of: uiElement.button!, preferredEdge: .maxY)
    }
    
    private func closePopOver() {
        
        popOverView.close()
    }
    
    private func preparePopOver(with vc: NSViewController?) {
        
        (vc as? MapViewController)?.delegate = self
        popOverView.contentViewController = vc
        popOverView.behavior = .transient
    }
    
    
    private func updateUI(modelData: WeatherData){
        
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
                
                let visibilityTitle = NSLocalizedString("Visibility", comment: "")
                title.append(" | \(visibilityTitle) : \(visibility)")
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
            menuItem.target = self
            break
            
        case Constants.MenuItemName.refresh:
            
            menuItem = NSMenuItem(title: item, action: #selector(refreshData), keyEquivalent: "R")
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
    

}

