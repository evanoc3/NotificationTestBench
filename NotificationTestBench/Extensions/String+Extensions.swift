//
//  String+Extensions.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 05/09/2022.
//

import Foundation


extension String {
    
    func stripPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func stripSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}
