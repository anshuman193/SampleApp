//
//  Utility.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/24/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation

enum ViewControllerType {
    
    case Map
}

class Utility: NSObject {
    
    class func readValue(fromplistFile name: String, forKey key: String) -> String? {
        
        var value: String?
        var dict: NSDictionary?
        
        if let path = Bundle.main.path(forResource: name, ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
        }
        
        if let valueForKey = dict?.value(forKey: key) as? String {
            value = valueForKey
        }
        
        return value
    }
    
}
