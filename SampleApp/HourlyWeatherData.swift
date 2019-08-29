//
//  WeatherData.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/25/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation


struct HourlyWeatherData: Codable {
    
    var summary: String?
    var hourlyDetailsArray: [HourlyWeatherDataDetails?]
    
    enum CodingKeys: String, CodingKey {

        case hourlyDetailsArray = "data"
    }
}


struct HourlyWeatherDataDetails: Codable {
    
    var time: Int?
    var summary: String?
    var temperature: Double?
    var feelsLikeTemperature: Double?
    var windSpeed: Double?
    var windGust: Double?
    var visibility: Double?
    
    enum Codingkeys: String, CodingKey {
        
        case feelsLikeTemperature = "apparentTemperature"
    }
}
