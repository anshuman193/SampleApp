//
//  Parser.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/25/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation
import SwiftyJSON

class Parser: NSObject {
    
    private var jsonData: JSON?
    private(set) var currWeatherInfo: CurrentWeatherInfo?
    
    override init() {
        
    }
    
    func parse(data: JSON){
        
        currWeatherInfo = CurrentWeatherInfo(json: data)
    }
}
