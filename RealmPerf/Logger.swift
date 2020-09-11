//
//  Logger.swift
//  RealmPerf
//
//  Created by floorish on 11/09/2020.
//  Copyright © 2020 floorish. All rights reserved.
//

import Foundation

class Logger {
    
    static func print(_ args: Any?..., file: String = #file, line: Int = #line) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "H:m:ss.SSSS"
        
        
        var threadID: UInt64 = 0
        pthread_threadid_np(nil, &threadID)
        let thread = String(format: "%08X", threadID)

        NSLog("👉 %@, %@, %@", thread, formatter.string(from: Date()), Logger.stringify(value: args))
        // Swift.print("👉", thread, formatter.string(from: Date()), Logger.stringify(value: args))
    }
    
    private static func stringify(value: Any?) -> String {
        if let values = value as? [Any?] {
            return values.map(Logger.optionalString(value:))
                .joined(separator: ", ")
        }
        
        return Logger.optionalString(value: value)
    }
    
    private static func optionalString(value: Any?) -> String {
        guard let v = value else {
            return "Nil"
        }
        
        return String(describing: v)
    }

}
