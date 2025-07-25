//
//  NotificationService.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import UserNotifications
import Combine

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    @Published var snowThreshold: Int = 20
    @Published var forecastNotificationsEnabled = true
    @Published var forecastNotificationTime = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()
    
    private let userNotificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if let error = error {
                    print("Notification authorization error: \(error)")
                }
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        userNotificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Snow Alerts
    
    func scheduleSnowAlert(snowAmount: Int, threshold: Int) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "❄️ Fresh Snow Alert!"
        content.body = "\(snowAmount)cm of fresh snow reported. Time to hit the slopes!"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        // Add action buttons
        let viewAction = UNNotificationAction(
            identifier: "VIEW_SNOW",
            title: "View Details",
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "SNOW_ALERT",
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        userNotificationCenter.setNotificationCategories([category])
        content.categoryIdentifier = "SNOW_ALERT"
        
        // Schedule immediate notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "snow-alert-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        userNotificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling snow alert: \(error)")
            }
        }
    }
    
    // MARK: - Forecast Notifications
    
    func scheduleForecastNotification(forecast: [DayForecast]) {
        guard isAuthorized && forecastNotificationsEnabled else { return }
        
        // Check if tomorrow has snow in the forecast
        let tomorrow = forecast.first { dayForecast in
            dayForecast.dayOfWeek == "Tomorrow" || dayForecast.snowfall > 0
        }
        
        guard let tomorrowForecast = tomorrow, tomorrowForecast.snowfall > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🌨️ Snow in Tomorrow's Forecast!"
        content.body = "\(tomorrowForecast.snowfall)cm of snow expected tomorrow. Get your gear ready!"
        content.sound = UNNotificationSound.default
        
        // Schedule for the user's preferred time (default 9 PM)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: forecastNotificationTime)
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "forecast-notification",
            content: content,
            trigger: trigger
        )
        
        userNotificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling forecast notification: \(error)")
            }
        }
    }
    
    // MARK: - Lift Notifications (Removed - Lift functionality cleared)
    
    // func scheduleLiftOpenNotification(lift: LiftData) {
    //     guard isAuthorized else { return }
    //     
    //     let content = UNMutableNotificationContent()
    //     content.title = "🚡 Lift Now Open!"
    //     content.body = "\(lift.name) is now open. Current wait time: \(lift.waitTime ?? 0) minutes."
    //     content.sound = UNNotificationSound.default
    //     
    //     let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    //     let request = UNNotificationRequest(
    //         identifier: "lift-open-\(lift.id)",
    //         content: content,
    //         trigger: trigger
    //     )
    //     
    //     userNotificationCenter.add(request) { error in
    //         if let error = error {
    //             print("Error scheduling lift notification: \(error)")
    //         }
    //     }
    // }
    
    // MARK: - Utility Methods
    
    func clearAllNotifications() {
        userNotificationCenter.removeAllPendingNotificationRequests()
        userNotificationCenter.removeAllDeliveredNotifications()
    }
    
    func sendTestNotification() {
        guard isAuthorized else {
            requestAuthorization()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Gorby gaap Test"
        content.body = "Your notifications are working perfectly! ⛷️"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: trigger
        )
        
        userNotificationCenter.add(request) { error in
            if let error = error {
                print("Error sending test notification: \(error)")
            }
        }
    }
} 