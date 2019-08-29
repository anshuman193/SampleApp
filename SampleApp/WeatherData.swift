//
//  WeatherData.swift
//  Tracker
//
//  Created by anshuman singh on 29/08/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation


struct WeatherData: Codable {

    var latitude: Double?
    var timezone: String?
    
    var hourly: HourlyWeatherData?
    
    struct HourlyWeatherData: Codable {
        var summary: String?
        var data: [HourlyWeatherDataDetails?]
    }
}

extension WeatherData {
    
}
