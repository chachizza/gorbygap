//
//  GorbyApp.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import SwiftUI
import WeatherKit
import CoreLocation

@main
struct GorbyApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        // Initialize Instagram token on app startup
        let instagramService = InstagramService()
        instagramService.initializeToken(
            "EAAOzNS0ZAF6wBPCE7ILXFiBItXRezOkGPcLEoG8ZBTdoS2StqZB1nsMdRXqrHjwsSJqXdbVpgbkNmyKt7sIsZBUiyDSN97GRe5mzyZCN4jeK6WZBacxIC2OUKLWpBk37wHOpcf2ZCvw4aYLQDi4SZBqyfXjzAaaawiO3hZABiz6Tzboo4of7Kv0Se2364MygCTsWL97gUxVLObXJT", 
            expiresIn: 5184000
        )
    }
    
    var body: some Scene {
        WindowGroup {
            WhistlerRideTabView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                .background(themeManager.currentTheme.backgroundColor)
        }
    }
}
