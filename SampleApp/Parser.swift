//
//  Parser.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/25/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation


protocol PareserDataUpdateDelegate: class {

    func newDataDidBecomeAvaialble(model: WeatherData)
}

class Parser: NSObject {
    
    
    weak var delegate: PareserDataUpdateDelegate?
    fileprivate var newData: Data?
    
    init(_ data: Data, delegate: PareserDataUpdateDelegate?) {
        
        super.init()
        newData = data
        self.delegate = delegate
    }
    
    func start() {
        
        guard let dataToParse = newData else {
            
            Logger.debugLog(Constants.ErrorMessage.kNothingToParse)
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
            
            Logger.debugLog(Constants.ErrorMessage.kParseErrorOccured + "\(error)")
        }
        
    }
}
