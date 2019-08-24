//
//  WebServiceHandler.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/24/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation
import SwiftyJSON

class WebServiceHandler: NSObject {
    
    private var latitude: Double?
    private var longitude: Double?
    private var datasource: String?
    
    
    
    private var apiKey: String? {
        return Utility.readValue(fromplistFile: "Config", forKey: "API Key")
    }
    
    init?(with baseurl: URL, latitude: Double, longitude: Double) {
        super.init()
        
        if let _apiKey = self.apiKey {
            
            let coordinates = String(format:"\(latitude),\(longitude)")
            self.datasource = baseurl.absoluteString + _apiKey + coordinates
            self.latitude = latitude
            self.longitude = longitude
        } else {
            Logger.debugLog("Can't initialize WebServiceHandler because API Key is nil")
            return nil
        }

    }

    private func prepareRequest(source: String) -> URL? {
        guard let url = URL(string: source) else { return nil }
        return url
        
    }
    
    func fetchData() {
        
        if self.datasource == "" {
            Logger.debugLog("Can't fetch data because datasource is nil")
            return
        }
        
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            
            guard let url = self.prepareRequest(source: self.datasource!) else { return }
            guard let data = try? String(contentsOf: url) else {
                DispatchQueue.main.async { [unowned self] in
//                    self.statusItem.button?.title = "Bad API call"
                }
                return
            }
            
            let newFeed = JSON(parseJSON: data)
            
            DispatchQueue.main.async {
//                self.feed = newFeed
//                self.updateDisplay()
//                self.refreshSubmenuItems()
            }
        }
    
    }
    
    
}
