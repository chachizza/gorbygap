//
//  SnowAlertsViewModel.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import UserNotifications

@MainActor
class SnowAlertsViewModel: ObservableObject {
    @Published var snowThreshold: Int = 20
    @Published var snowAlertsEnabled: Bool = false
    @Published var wakeUpTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    @Published var hourlyCheck: Bool = false
    @Published var recentAlerts: [SnowAlert] = []
    
    init() {
        loadSettings()
        loadRecentAlerts()
        requestNotificationPermission()
    }
    
    func loadSettings() {
        // In a real app, load from UserDefaults
        snowThreshold = UserDefaults.standard.object(forKey: "snowThreshold") as? Int ?? 20
        snowAlertsEnabled = UserDefaults.standard.bool(forKey: "snowAlertsEnabled")
        hourlyCheck = UserDefaults.standard.bool(forKey: "hourlyCheck")
    }
    
    func saveSettings() {
        UserDefaults.standard.set(snowThreshold, forKey: "snowThreshold")
        UserDefaults.standard.set(snowAlertsEnabled, forKey: "snowAlertsEnabled")
        UserDefaults.standard.set(hourlyCheck, forKey: "hourlyCheck")
    }
    
    func loadRecentAlerts() {
        recentAlerts = SnowAlert.mockAlerts
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Whistler Snow Alert Test"
        content.body = "This is a test notification. Your snow alerts are working!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Test notification error: \(error)")
            }
        }
    }
} 