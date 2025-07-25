//
//  ThemeSelectorView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-18.
//

import SwiftUI

struct ThemeSelectorView: View {
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 40))
                        .foregroundColor(themeManager.currentTheme.accentColor)
                    
                    Text("Choose Theme")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.currentTheme.textColor)
                    
                    Text("Select your preferred color scheme")
                        .font(.subheadline)
                        .foregroundColor(themeManager.currentTheme.textColor.opacity(0.7))
                }
                .padding(.top, 20)
                
                // Theme Options
                VStack(spacing: 16) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        ThemeOptionCard(
                            theme: theme,
                            isSelected: themeManager.currentTheme == theme,
                            themeManager: themeManager
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Current Theme Info
                VStack(spacing: 8) {
                    Text("Current Theme")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))
                    
                    Text(themeManager.currentTheme.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                }
                .padding(.bottom, 20)
            }
            .background(themeManager.currentTheme.backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
                .foregroundColor(themeManager.currentTheme.accentColor)
            )
        }
    }
}

struct ThemeOptionCard: View {
    let theme: AppTheme
    let isSelected: Bool
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                themeManager.setTheme(theme)
            }
        }) {
            HStack(spacing: 16) {
                // Theme Icon
                Image(systemName: theme.iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : theme.accentColor)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(
                                isSelected ? 
                                LinearGradient(
                                    colors: [theme.secondaryAccentColor, theme.accentColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [theme.cardBackgroundColor, theme.cardBackgroundColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                
                // Theme Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textColor)
                    
                    Text(themeDescription(for: theme))
                        .font(.caption)
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
                
                Spacer()
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(theme.accentColor)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? theme.accentColor : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func themeDescription(for theme: AppTheme) -> String {
        switch theme {
        case .light:
            return "Clean and bright interface"
        case .dark:
            return "Easy on the eyes at night"
        case .greyscale:
            return "Minimalist black and white"
        }
    }
}

#Preview {
    ThemeSelectorView(themeManager: ThemeManager())
} 