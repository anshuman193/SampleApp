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
    func newDataDidBecomeAvaialble(models: [CurrentWeatherInfo?])
}

class Parser: NSObject {
    
    
    weak var delegate: PareserDataUpdateDelegate?
    fileprivate var jsonData: JSON?
    fileprivate(set) var weatherInfo: HourlyWeatherData?
    
    func parse(data: JSON){
        
        weatherInfo = HourlyWeatherData(json: data)
        if let dataArr = weatherInfo?.dataArray {
          self.delegate?.newDataDidBecomeAvaialble(models: dataArr)
        }
        

    }
}
