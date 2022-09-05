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
    
    private static var singletonInstance: NotificationManager?
    public static var shared: NotificationManager {
        if singletonInstance == nil {
            singletonInstance = NotificationManager()
        }
        return singletonInstance!
    }
    
    
    // MARK: Fields
    
	private(set) var deliveredNotifications: [UNNotificationRequest] = []
	private var notificationIdCounter: Int = 0
    
    
    // MARK: Lifecycle
    
    private override init() {
        super.init()
        
        print("Created new NotificationManager instance")
        UNUserNotificationCenter.current().delegate = self
    }
    
    
    // MARK: Public API
    
    public func requestAuthorization(for forOptions: UNAuthorizationOptions) {
        print("Requesting authorization for user notifications")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in
            if let error = error {
                print("Error 1: \(error.localizedDescription)")
                return
            }
            
            print("Request for authorization: \(granted ? "granted" : "denied")")
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
           
           print("Checking whether notifications are allowed:")
           print("\tBadge: \(notificationSettings.alertSetting.toString)")
           print("\tSound: \(notificationSettings.soundSetting.toString)")
           print("\tAlert: \(notificationSettings.alertSetting.toString)")
           print("\tCritical: \(notificationSettings.criticalAlertSetting.toString)")
           print("\tTime Sensitive: \(notificationSettings.timeSensitiveSetting.toString)")
		   
           guard notificationSettings.alertSetting == .enabled || notificationSettings.badgeSetting == .enabled || notificationSettings.soundSetting == .enabled else { return }
		   print("Attempting to send notification")
           
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
           
		   // create a unique ID for the notification
		   let notificationId = "notification-\(self.notificationIdCounter)"
		   self.notificationIdCounter += 1
		   
		   // create the notification request
           let notificationRequest = UNNotificationRequest(identifier: notificationId, content: notificationContent, trigger: nil)
           UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { [weak self, notificationId] error in
               if let error = error {
                   print("Error 4: \(error.localizedDescription)")
                   return
               }
               
               print("Notification \"\(notificationId)\" delivered successfully")
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
		if #available(macOS 11.0, *) {
			completionHandler([.banner, .badge, .sound])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }
    
}
