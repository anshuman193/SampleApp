//
//  Parser.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/25/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol PareserDataUpdateDelegate: class {
//    associatedtype M
    func newDataDidBecomeAvaialble(model: WeatherData)
}

class Parser: NSObject {
    
    
    weak var delegate: PareserDataUpdateDelegate?
    fileprivate var newData: Data?
//    fileprivate(set) var weatherInfo: HourlyWeatherData
    
    init(_ data: Data) {
        
        super.init()
        newData = data
    }
    
    func start() {
        
        guard let dataToParse = newData else {
            
            Logger.debugLog("No data to parse...parsing aborted")
            return
        }
        
        parse(data: dataToParse)
    }
    
    private func parse(data: Data){
        
        let decoder = JSONDecoder()
        
        do {
            
            let decodedData = try decoder.decode(WeatherData.self, from: data)
            self.delegate?.newDataDidBecomeAvaialble(model: decodedData)
            
        } catch let error {
            
            Logger.debugLog("Parsing error \(error)")
        }
        
    }
}
