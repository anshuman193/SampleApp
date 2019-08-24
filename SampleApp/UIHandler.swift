//
//  UIManager.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/24/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation
import AppKit

@objcMembers class UIHandler<T> {}

extension UIHandler where T == NSStatusItem {
    
    
    func initializeUI(uiElement: NSStatusItem) {
        
        let statusItem = uiElement
        statusItem.button?.title = agentName(plistname: "Info", and: "Agent Name")
        Logger.debugLog("initializeUI called")
    }
    
    func makePopOver(vc: NSViewController, uiElement: T) -> Void {
        let popOverView = constructPopOver(vc)
        displayPopOver(popOverView, uiElement: uiElement)
    }
    
    
    //MARK: helper methods

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

}

