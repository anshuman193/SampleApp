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
    
    
    init?(json: JSON){
        
        if let _summary = json["summary"].string{
            summary = _summary
        }
        
        if let _time = json["time"].double {
            time = _time
        }
        
        if let _temperature = json["temperature"].int {
            temperature = _temperature
        }
        
        if let _humidity = json["humidity"].int {
            humidity = _humidity
        }
    }
    
}


struct HourlyWeatherDataDetails: Codable {
    
    
    /*
 
 {"time":1566725400,"summary":"Mostly Cloudy","icon":"partly-cloudy-day","precipIntensity":0,"precipProbability":0,"temperature":88.96,"apparentTemperature":92.84,"dewPoint":68.12,"humidity":0.5,"pressure":1005.21,"windSpeed":16.42,"windGust":22.07,"windBearing":267,"cloudCover":0.64,"uvIndex":5,"visibility":10,"ozone":265.9}
 
 */
    
    
    
    
    var time: Int?
    var summary: String?
    var temperature: Double?
    var feelsLikeTemperature: Double?
    var windSpeed: Double?
    var windGust: Double?
    var visibility: Int?
    
    enum Codingkeys: String, CodingKey {
        
        case feelsLikeTemperature = "apparentTemperature"
    }
    
    
//    var dataArray = [CurrentWeatherInfo?]()
//    var timeZone: String?
//
//    init(json: JSON) {
//
//        for data in json["hourly"]["data"].arrayValue.prefix(10){
//
//            if let weatherInfo = CurrentWeatherInfo(json: data) {
//                dataArray.append(weatherInfo)
//            }
//        }
//
//        if let timezone = json["timezone"].string {
//            self.timeZone = timezone
//        }
//    }
    
}
