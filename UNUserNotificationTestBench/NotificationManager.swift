//
//  NotificationManager.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 01/09/2022.
//

import AppKit
import UserNotifications


class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    // MARK: Static Fields
    
    public static var shared = NotificationManager()
    
    
    // MARK: Fields
    
    public var presentationOptions: UNNotificationPresentationOptions {
        didSet {
            var msg = "Setting presentation options to: "
            if presentationOptions.contains(.banner) { msg += "banner, " }
            if presentationOptions.contains(.list) { msg += "list, " }
            if presentationOptions.contains(.alert) { msg += "alert, " }
            if presentationOptions.contains(.badge) { msg += "badge, " }
            if presentationOptions.contains(.sound) { msg += "sound, " }
            msg = msg.stripSuffix(", ") + "."
            log(msg)
        }
    }
	private(set) var deliveredNotifications: [UNNotificationRequest] = []
	private var notificationIdCounter: Int = 0
    
    
    // MARK: Lifecycle
    
    private override init() {
        if #available(macOS 11.0, *) {
            presentationOptions = [.banner, .list, .badge, .sound]
        } else {
            presentationOptions = [.alert, .badge, .sound]
        }
        
        super.init()
        
        log("New NotificationManager instance created")
        UNUserNotificationCenter.current().delegate = self
    }
    
    
    // MARK: Public API
    
    public func requestAuthorization(for forOptions: UNAuthorizationOptions) {
        log("Requesting authorization for notifications")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in
            if let error = error {
                log("Error requesting authorization. Error: \(error.localizedDescription)")
                return
            }
            
            log("Request for authorization: \(granted ? "granted" : "denied")")
        })
    }
    
    public func hasAuthorizationBeenRequested(callback: @escaping (Bool) -> Void) {
        checkNotificationsAuthorization(callback: { [callback] notificationSettings in
            callback(!(notificationSettings.alertSetting == .notSupported &&
                       notificationSettings.badgeSetting == .notSupported &&
                       notificationSettings.soundSetting == .notSupported))
        })
    }
    
    public func removePendingAndDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        deliveredNotifications = []
		
        NotificationCenter.default.post(name: NSNotification.deliveredNotificationsChanged, object: self)
    }

    public func sendNotification(content: UNNotificationContent) {
        checkNotificationsAuthorization(callback: { [weak self, content] notificationSettings in
            guard let self = self else { return }
           
            log("""
                Checking whether notifications are allowed:
                Badge (\(notificationSettings.alertSetting.toString)),
                Sound (\(notificationSettings.soundSetting.toString)),
                Alert (\(notificationSettings.alertSetting.toString)),
                Critical (\(notificationSettings.criticalAlertSetting.toString)),
                Time Sensitive (\(notificationSettings.timeSensitiveSetting.toString)).
            """)
		   
            guard notificationSettings.alertSetting == .enabled || notificationSettings.badgeSetting == .enabled || notificationSettings.soundSetting == .enabled else { return }
            log("Attempting to send notification")
           
            // create a new UNNotificationContent object with fields filled depending on the allowed settings
            let notificationContent = UNMutableNotificationContent()
            if notificationSettings.alertSetting == .enabled {
               notificationContent.title = content.title
               notificationContent.subtitle = content.subtitle
               notificationContent.body = content.body
               notificationContent.attachments = content.attachments
            }
            if notificationSettings.badgeSetting == .enabled {
               notificationContent.badge = content.badge
            }
            if notificationSettings.soundSetting == .enabled {
               notificationContent.sound = content.sound
            }
            if !content.categoryIdentifier.isEmpty {
                notificationContent.categoryIdentifier = content.categoryIdentifier
            }

            // create a unique ID for the notification
            let notificationId = "notification-\(self.notificationIdCounter)"
            self.notificationIdCounter += 1

            // create the notification request
            let notificationRequest = UNNotificationRequest(identifier: notificationId, content: notificationContent, trigger: nil)
            UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { [weak self, notificationId] error in
                if let error = error {
                    log("Error sending notification. Error: \(error.localizedDescription)")
                    return
                }

                log("Notification \"\(notificationId)\" delivered successfully")
                guard let self = self else { return }
                self.deliveredNotifications.append( notificationRequest )
                NotificationCenter.default.post(name: NSNotification.deliveredNotificationsChanged, object: self)
            })
       })
   }
    
    public func removeNotification(withIdentifier notificationId: String) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [ notificationId ])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [ notificationId ])
        
        deliveredNotifications = deliveredNotifications.filter({ $0.identifier != notificationId  })
        
        NotificationCenter.default.post(name: NSNotification.deliveredNotificationsChanged, object: self)
    }
    
    public func checkNotificationsAuthorization(callback: @escaping (UNNotificationSettings) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            callback(settings)
        })
    }
    
    
    // MARK: UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(presentationOptions)
        return
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Selected action \"\(response.actionIdentifier)\" on notification \"\(response.notification.request.identifier)\"")
        completionHandler()
    }
    
}
