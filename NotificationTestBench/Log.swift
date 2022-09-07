//
//  Log.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 07/09/2022.
//

import Foundation


public func log(_ msg: String? = nil, filepath: String = #file, function: String = #function, line: Int = #line) {
    let filePathParts = filepath.components(separatedBy: "/")
    let filename = filePathParts.last!
    
    if let msg = msg {
        print("\(filename) \(function):\(line): \(msg)")
    }
    else {
        print("\(filename) \(function):\(line)")
    }
}
