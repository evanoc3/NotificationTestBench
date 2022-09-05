//
//  NSNotification+Extensions.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 05/09/2022.
//

import AppKit


extension NSNotification {
    
    public static let deliveredNotificationsChanged = NSNotification.Name("delivered-notification-changed")
    public static let notificationsNotSupported = NSNotification.Name("notifications-not-supported")
    
}
