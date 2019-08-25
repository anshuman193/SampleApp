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
    func newDataDidBecomeAvaialble()
}

class Parser: NSObject {
    
    
    var delegate: PareserDataUpdateDelegate?
    private var jsonData: JSON?
    private(set) var currWeatherInfo: CurrentWeatherInfo?
    
    func parse(data: JSON){
        
        currWeatherInfo = CurrentWeatherInfo(json: data)

        self.delegate?.newDataDidBecomeAvaialble()
        
    }
}
