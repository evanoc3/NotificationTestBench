//
//  IntegerFormatter.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 01/09/2022.
//

import Foundation


class IntegerFormatter: NumberFormatter {

    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {

        if partialString.isEmpty {
            return true
        }

        return Int(partialString) != nil
    }
}
