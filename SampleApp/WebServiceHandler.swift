//
//  WebServiceHandler.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/24/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol WebServiceProtocol {
    
    func startAnimation()
    func stopAnimation()
}

class WebServiceHandler: NSObject {
    
    var delegate: WebServiceProtocol?
    fileprivate var latitude: Double?
    fileprivate var longitude: Double?
    fileprivate var datasource: String?
    fileprivate var responseParser = Parser()
    
    
    fileprivate var apiKey: String? {
        return Utility.readValue(fromplistFile: "Config", forKey: "API Key")
    }
    
    init?(with baseurl: String, latitude: Double, longitude: Double, parserDelegate delegate:PareserDataUpdateDelegate) {
        super.init()
        
        if let _apiKey = self.apiKey {
            
            let coordinates = String(format:"\(latitude),\(longitude)")
            self.datasource = baseurl + _apiKey + "/" + coordinates
            self.latitude = latitude
            self.longitude = longitude
            responseParser.delegate = delegate
        } else {
            Logger.debugLog("Can't initialize WebServiceHandler because API Key is nil")
            return nil
        }

    }

    fileprivate func prepareRequest(source: String) -> URL? {
        guard let url = URL(string: source) else { return nil }
        return url
        
    }
    
    func fetchData() {
        
        if self.datasource == "" {
            Logger.debugLog("Can't fetch data because datasource is nil")
            return
        }
        
        self.delegate?.startAnimation()
        
        DispatchQueue.global(qos: .utility).async {
            
            guard let url = self.prepareRequest(source: self.datasource!) else { return }
            Logger.debugLog("url --> \(url)")
            guard let data = try? String(contentsOf: url) else {
                DispatchQueue.main.async {
                    
                    Logger.debugLog("Problem in API call")
                }
                return
            }
            
            let newData = JSON(parseJSON: data)
            Logger.debugLog("response::::::::>>>>> \(newData)")
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: { //TODO: Delay induced for demo purpose
                self.responseParser.parse(data: newData)
                self.delegate?.stopAnimation()

            })
            
//            DispatchQueue.main.async {
//                    self.responseParser.parse(data: newData)
//                    self.delegate?.stopAnimation()
//                }
            
            }
        }
    
}
    




