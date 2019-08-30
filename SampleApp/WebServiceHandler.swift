//
//  WebServiceHandler.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/24/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation

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
    private var latitude: Double?
    private var longitude: Double?
    private var datasource: String?
    private var dataUpdateDelegate: PareserDataUpdateDelegate?
    
    
    private var apiKey: String? {
        return Utility.readValue(fromplistFile: "Config", forKey: "API Key")
    }
    
    init?(with baseurl: String?, latitude: Double, longitude: Double, parserDelegate delegate:PareserDataUpdateDelegate) {
        super.init()
        
        if let _apiKey = self.apiKey, let baseURL = baseurl {
            
            let coordinates = String(format:"\(latitude),\(longitude)")
            self.datasource = baseURL + _apiKey + "/" + coordinates
            self.latitude = latitude
            self.longitude = longitude
            self.dataUpdateDelegate = delegate
        } else {
            
            Logger.debugLog("Can't initialize WebServiceHandler because API Key or base URL is nil")
            return nil
        }

    }

    private func prepareRequest(source: String) -> URL? {
        
        guard let url = URL(string: source) else { return nil }
        return url
        
    }
    
    func fetchData() {
 
        self.delegate?.startAnimation()
        
        DispatchQueue.global(qos: .utility).async {
            
            guard let dataSrc = self.datasource else {
                
                Logger.debugLog(Constants.ErrorMessage.badDataSource)
                return
            }
            
            guard let url = self.prepareRequest(source: dataSrc) else {
                
                Logger.debugLog(Constants.ErrorMessage.badURL)
                return
            }
            
            Logger.debugLog("url --> \(url)")
            
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                guard let newData = data else {
                    
                    Logger.debugLog(Constants.ErrorMessage.noDataAvailable)
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: { //TODO: Delay induced for demo purpose
                    
                    let responseParser = Parser(newData, delegate: self.dataUpdateDelegate)
                    responseParser.start()
                    self.delegate?.stopAnimation()
                    
                })
                
            }).resume()
            
            }
        }
    
}
    




