//
//  Logger.swift
//  Tracker
//
//  Created by Anshuman Singh on 8/24/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Foundation

class Logger: NSObject {
    
    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
 
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }

    
    private static var isLoggingEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    class func debugLog( _ object: Any) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(object)")
        }
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

internal extension Date {
    func toString() -> String {
        return Logger.dateFormatter.string(from: self as Date)
    }
}
