//
//  AlertProvider.swift
//  Listio
//
//  Created by Felipe Dias Pereira on 2017-08-06.
//  Copyright © 2017 Felipe Dias Pereira. All rights reserved.
//

import UIKit
import UserNotifications

class AlertProvider: NSObject, UNUserNotificationCenterDelegate {
    var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }

     func registerForLocalNotification(on application: UIApplication) -> Bool {
        if UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            let notificationCategory: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            notificationCategory.identifier = "NOTIFICATION_CATEGORY"
            application.registerUserNotificationSettings(
                UIUserNotificationSettings(types:[.sound, .alert, .badge], categories: nil))
            return true
        }
        return false
    }

     func dispatchlocalNotification(with title: String,
                                    body: String,
                                    userInfo: [AnyHashable: Any]? = nil,
                                    at date: Date) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.categoryIdentifier = "Fechou"
            if let info = userInfo {
                content.userInfo = info
                if let uid = info[Constants.notificationIdentifierKey] as? String {
                    content.sound = UNNotificationSound.default()
                    content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
                    let comp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
                    let request = UNNotificationRequest(identifier: uid, content: content, trigger: trigger)
                    removeLocalNotificationByIdentifier(withID: uid)
                    UNUserNotificationCenter.current().add(request) { (error) in
                        if error != nil {
                            print(error?.localizedDescription ?? "")
                        } else {
                            print("Successfully Done")
                        }
                    }
                }
            }
        } else {
            let notification = UILocalNotification()
            var datecomponent = DateComponents()
            datecomponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            notification.fireDate = Calendar.current.date(from: datecomponent)
            notification.alertTitle = title
            notification.alertBody = body
            notification.timeZone = NSTimeZone.system
            if let info = userInfo {
                notification.userInfo = info
                if let uid = info[Constants.notificationIdentifierKey] as? String {
                    removeLocalNotificationByIdentifier(withID: uid)
                }
            }
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        print("WILL DISPATCH LOCAL NOTIFICATION AT ", date)
    }

     func removeLocalNotificationByIdentifier(withID identifer: String? = nil) {
        if #available(iOS 10.0, *) {
            guard identifer != nil else { return }
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                var identifiers: [String] = []
                for notification: UNNotificationRequest in notificationRequests
                    where notification.identifier == identifer {
                    identifiers.append(notification.identifier)
                }
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            }
        } else {
            let app: UIApplication = UIApplication.shared
            for oneEvent in app.scheduledLocalNotifications! {
                let notification = oneEvent as UILocalNotification
                if let userInfoCurrent = notification.userInfo as? [String:AnyObject],
                    let uid = userInfoCurrent[Constants.notificationIdentifierKey] as? String {
                    if uid == identifer {
                        app.cancelLocalNotification(notification)
                        break
                    }
                }
            }

        }
    }
}
