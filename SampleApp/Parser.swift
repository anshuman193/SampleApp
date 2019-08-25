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
    func newDataDidBecomeAvaialble(model: CurrentWeatherInfo)
}

class Parser: NSObject {
    
    
    var delegate: PareserDataUpdateDelegate?
    private var jsonData: JSON?
    private(set) var currWeatherInfo: CurrentWeatherInfo?
    
    func parse(data: JSON){
        
        currWeatherInfo = CurrentWeatherInfo(json: data)
        
        guard let _ = currWeatherInfo else { return }
        self.delegate?.newDataDidBecomeAvaialble(model: currWeatherInfo!)
    }
}
