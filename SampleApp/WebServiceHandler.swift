//
//  WebServiceHandler.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/24/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol WebServiceProtocol: class {
    
    func startAnimation()
    func stopAnimation()
    func parseData(data: Data)
}

extension WebServiceProtocol {
    
    func parseData(data: Data){}
}

class WebServiceHandler: NSObject {
    
    weak var delegate: WebServiceProtocol?
    fileprivate var latitude: Double?
    fileprivate var longitude: Double?
    fileprivate var datasource: String?
//    fileprivate var responseParser: Parser?
    
    
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
//            guard let data = try? String(contentsOf: url) else {
//                DispatchQueue.main.async {
//                    Logger.debugLog("Problem in API call")
//                }
//                return
//            }
            
//            let newData = JSON(parseJSON: data)
//            Logger.debugLog("response::::::::>>>>> \(data)")
            
            
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                guard let newData = data else {
                    
                    Logger.debugLog("No data available")
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: { //TODO: Delay induced for demo purpose
                    
                    let responseParser = Parser(newData)
                    responseParser.start()
                    self.delegate?.stopAnimation()
                    
                })
                
            }).resume()
            

            
//            URLSession.shared.dataTask(with: self.datasource) { (data, response
//                , error) in
//                
//            }.resume
            
     
            
            }
        }
    
}
    




