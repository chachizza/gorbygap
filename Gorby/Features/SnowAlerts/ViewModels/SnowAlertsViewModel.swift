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
        // Load from UserDefaults
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
        // TODO: Load real snow alerts from API when implemented
        // For now, show empty state - no mock data
        recentAlerts = []
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func sendTestNotification() {
        guard isAuthorized else {
            print("❌ Notifications not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "❄️ Snow Alert Test"
        content.body = "This is a test notification from Gorby"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-notification-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Test notification error: \(error)")
            } else {
                print("✅ Test notification scheduled")
            }
        }
    }
    
    private var isAuthorized: Bool {
        // TODO: Implement proper authorization check
        return true
    }
}
