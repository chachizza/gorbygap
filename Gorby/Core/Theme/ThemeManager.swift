//
//  ThemeManager.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import SwiftUI

enum AppTheme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case greyscale = "Greyscale"
    
    var colorScheme: ColorScheme {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .greyscale:
            return .dark // Greyscale uses dark mode as base
        }
    }
    
    var iconName: String {
        switch self {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .greyscale:
            return "circle.lefthalf.filled"
        }
    }
    
    // Custom color schemes for each theme
    var backgroundColor: Color {
        switch self {
        case .light:
            return Color(red: 0.98, green: 0.98, blue: 0.98) // Light gray
        case .dark:
            return Color(red: 0.1, green: 0.1, blue: 0.12) // Dark gray
        case .greyscale:
            return Color(red: 0.08, green: 0.08, blue: 0.08) // Very dark gray
        }
    }
    
    var cardBackgroundColor: Color {
        switch self {
        case .light:
            return .white
        case .dark:
            return Color(red: 0.15, green: 0.15, blue: 0.17) // Slightly lighter dark
        case .greyscale:
            return Color(red: 0.12, green: 0.12, blue: 0.12) // Dark gray
        }
    }
    
    var textColor: Color {
        switch self {
        case .light:
            return Color(red: 0.1, green: 0.1, blue: 0.1) // Dark text
        case .dark:
            return .white
        case .greyscale:
            return Color(red: 0.9, green: 0.9, blue: 0.9) // Light gray text
        }
    }
    
    var accentColor: Color {
        switch self {
        case .light:
            return Color(red: 1.0, green: 0.3, blue: 0.7) // Hot pink
        case .dark:
            return Color(red: 1.0, green: 0.3, blue: 0.7) // Hot pink
        case .greyscale:
            return Color(red: 0.7, green: 0.7, blue: 0.7) // Light gray accent
        }
    }
    
    var secondaryAccentColor: Color {
        switch self {
        case .light:
            return Color(red: 0.6, green: 0.2, blue: 1.0) // Purple
        case .dark:
            return Color(red: 0.6, green: 0.2, blue: 1.0) // Purple
        case .greyscale:
            return Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? AppTheme.light.rawValue
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .light
    }
    
    func toggleTheme() {
        switch currentTheme {
        case .light:
            currentTheme = .dark
        case .dark:
            currentTheme = .greyscale
        case .greyscale:
            currentTheme = .light
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
} 