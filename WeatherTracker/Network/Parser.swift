//
//  Parser.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/25/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation


protocol PareserDataUpdateProtocol: class {

    func didParseData(model: WeatherData?)
}

class Parser: NSObject {
    
    
    weak var delegate: PareserDataUpdateProtocol?
 
    private var newData: Data?
    
    private var decodedData: WeatherData? {
        
        didSet {
            delegate?.didParseData(model: decodedData)
        }
    }
    
    init(_ data: Data, delegate: PareserDataUpdateProtocol?) {
        
        super.init()
        newData = data
        self.delegate = delegate
        start()
    }
    
    
    private func start() {
        
        guard let dataToParse = newData else {
            
            Logger.debugLog(Constants.ErrorMessage.nothingToParse)
            return
        }
        
        parse(data: dataToParse)
    }
    
    private func parse(data: Data){
        
        let decoder = JSONDecoder()
        
        do {
            
            decodedData = try decoder.decode(WeatherData.self, from: data)

        } catch let error {
            
            Logger.debugLog(Constants.ErrorMessage.parseErrorOccured + "\(error)")
        }
        
    }
}
