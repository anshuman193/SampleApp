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
    private var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private init(){}
    private var dataModelArr: [CurrentWeatherInfo]?
}

extension AgentUICoordinator {
    
    func setup(withTitle name: String) {
        
        statusItem.button?.title = name
        Logger.debugLog("initializeUI called")
    }
    
    func refreshMenuItems(model: [CurrentWeatherInfo]) {

        dataModelArr = model
        guard let _ = dataModelArr else { return }
        updateSubmenuItems(modelArray: dataModelArr!)
    }
    
    func configMenuItems() {

        statusItem.menu = NSMenu()
        let settingMenuItem = NSMenuItem(title: "Settings", action: #selector(settings), keyEquivalent: " ")
        settingMenuItem.target = self
        statusItem.menu?.addItem(settingMenuItem)
    }

    @objc private func settings(){

        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "mapviewcontroller") as? NSViewController else { return }
        makePopOver(vc: vc, uiElement: statusItem)
    }

    
    func makePopOver(vc: NSViewController, uiElement: NSStatusItem) -> Void {
        let popOverView = constructPopOver(vc)
        displayPopOver(popOverView, uiElement: self.statusItem)
        Logger.debugLog("makePopOver called")
    }
    
    //MARK: helper methods

        
    
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
    
    private func updateSubmenuItems(modelArray: [CurrentWeatherInfo]) {
        
        statusItem.menu?.removeAllItems()
        
        for model in modelArray {
            
            if let time = model.time {
                
                let date = Date(timeIntervalSince1970: time)
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                let formattedDate = formatter.string(from: date)

                let summary = model.summary
                let temperature = model.temperature
                let title = "\(formattedDate): \(String(describing: summary)) (\(String(describing: temperature))°)"

                let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                statusItem.menu?.addItem(menuItem)
             

            }
        }
        
    }

}

