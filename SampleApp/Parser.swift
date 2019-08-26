//
//  Parser.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/25/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol PareserDataUpdateDelegate {
//    associatedtype M
    func newDataDidBecomeAvaialble(models: [CurrentWeatherInfo])
}

class Parser: NSObject {
    
    
    var delegate: PareserDataUpdateDelegate?
    fileprivate var jsonData: JSON?
    fileprivate(set) var currWeatherInfo: CurrentWeatherInfo?
    
    func parse(data: JSON){
        
        currWeatherInfo = CurrentWeatherInfo(json: data)

        if let weatherData = currWeatherInfo {
            
            var dataModelArr = [CurrentWeatherInfo]()
            dataModelArr.append(weatherData)
            self.delegate?.newDataDidBecomeAvaialble(models: dataModelArr)
        }

    }
}
