//
//  WeatherData.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/25/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation
import SwiftyJSON


struct CurrentWeatherInfo {
    
    var summary : String?
    var time : Double?
    var temperature : Int?
    var humidity : Int?
    
    
    init(json: JSON){
        
        if let _summary = json["currently"]["summary"].string{
            summary = _summary
        }
        
        if let _time = json["currently"]["time"].double {
            time = _time
        }
        
        if let _temperature = json["currently"]["temperature"].int {
            temperature = _temperature
        }
        
        if let _humidity = json["currently"]["humidity"].int {
            humidity = _humidity
        }
    }
    
}
