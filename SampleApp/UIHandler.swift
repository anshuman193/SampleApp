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

@objcMembers class UIHandler {
    
    static let shared = UIHandler()
    private init(){}
    private var statusItem: NSStatusItem?
}

extension UIHandler {
    
    func setup(uiElement: NSStatusItem) {
        
        self.statusItem = uiElement
        if let element = self.statusItem {
            element.button?.title = agentName(plistname: "Info", and: "Agent Name")
        }
        
        Logger.debugLog("initializeUI called")
    }
    
//    func configMenuItems(uiElement: NSStatusItem) {
//        let statusItem = uiElement
//        statusItem.menu = NSMenu()
//        let settingMenuItem = NSMenuItem(title: "Settings", action: #selector(settings), keyEquivalent: " ")
//        statusItem.menu?.addItem(settingMenuItem)
//        statusItem.menu?.item(withTitle: "Settings")?.isEnabled = true
//    }
//
//    @objc private func settings(){
//
//        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
//        guard let vc = storyboard.instantiateController(withIdentifier: "viewcontroller1") as? NSViewController else { return }
//
//        if let _ = self.statusItem {
//            UIHandler.shared.makePopOver(vc: vc, uiElement: self.statusItem!)
//        }
//    }

    
    func makePopOver(vc: NSViewController, uiElement: NSStatusItem) -> Void {
        let popOverView = constructPopOver(vc)
        displayPopOver(popOverView, uiElement: uiElement)
        Logger.debugLog("makePopOver called")
    }
    
    //MARK: helper methods

    private func agentName(plistname name: String, and key : String) -> String {
        
        var agentName = "Tracker" // default value
        
        if let value = Utility.readValue(fromplistFile: "Config" , forKey: key) {
            agentName = value
        }

        return agentName
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
    
    func updateSubmenuItems(model: CurrentWeatherInfo?) {
        
        if let dataModel = model, let time = dataModel.time {
            
            guard let element = self.statusItem else { return }
            
            element.menu?.removeAllItems()
            
            let date = Date(timeIntervalSince1970: time)
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let formattedDate = formatter.string(from: date)

            let summary = dataModel.summary
            let temperature = dataModel.temperature
            let title = "\(formattedDate): \(String(describing: summary)) (\(String(describing: temperature))°)"

            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            element.menu?.addItem(menuItem)

            

        }
        
    }

}

