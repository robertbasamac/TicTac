//
//  NotificationManager.swift
//  TicTac
//
//  Created by Robert Basamac on 08.10.2022.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
        
    static let instance = NotificationManager()
    
    func requestAuthorization() {
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, error) in
            if let error = error {
                print("ERROR: \(error)")
            } else {
                print("SUCCESS")
            }
        }
    }
    
    func scheduleNotification(title: String, alarmTime: Date) {
        
        let content = UNMutableNotificationContent()
        
        content.title = title
//        content.subtitle = "Subtitle"
        content.sound = .default
//        content.badge = 1

        let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: alarmTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: title, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
