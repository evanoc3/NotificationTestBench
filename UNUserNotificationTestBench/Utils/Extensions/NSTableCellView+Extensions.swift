//
//  NSTableCellView+Extensions.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 05/09/2022.
//

import AppKit
import UserNotifications


extension NSTableCellView {
    
    func setNotificationId(notificationId: String) {
        textField?.stringValue = notificationId.stripPrefix("notification-")
    }
    
    func setTitle(title: String) {
        textField?.stringValue = title
        textField?.toolTip = title
    }
    
    func setSubtitle(subtitle: String) {
        textField?.stringValue = subtitle
        textField?.toolTip = subtitle
    }
    
    func setBadge(badge: NSNumber?) {
        if let badge = badge {
            textField?.stringValue = badge.stringValue
            textField?.toolTip = "Badge: \(badge.stringValue)"
            return
        }
        
        textField?.stringValue = ""
        textField?.toolTip = "Badge: not set"
    }
    
    func setSound(sound: UNNotificationSound?) {
        if let sound = sound {
            textField?.stringValue = (sound == UNNotificationSound.default) ? "✅" : ""
            textField?.toolTip = (sound == UNNotificationSound.default) ? "Sound: default" : "Sound: n/a"
            return
        }
        
        textField?.stringValue = ""
        textField?.toolTip = "Sound: not set"
    }
    
    func setAttachment(attachment: UNNotificationAttachment?) {
        if let attachment = attachment {
            textField?.stringValue = attachment.url.absoluteString
            textField?.toolTip = "Attachment: \(attachment.url.absoluteString)"
            return
        }
        
        textField?.stringValue = ""
        textField?.toolTip = "Attachment: not set"
    }
    
    func setCategory(category: String) {
        textField?.stringValue = category
        textField?.toolTip = category
    }
}
