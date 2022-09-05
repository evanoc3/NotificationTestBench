//
//  UNNotificationSetting+Extensions.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 29/08/2022.
//

import Foundation
import UserNotifications


// MARK: - UNNotificationSetting Extension
extension UNNotificationSetting {
    public var toString: String {
        switch self {
            case .enabled:
                return "enabled"
            case .disabled:
                return "disabled"
            case .notSupported:
                return "notSupported"
            @unknown default:
                return ""
        }
    }
}
