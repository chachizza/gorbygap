//
//  SettingsView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-18.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingThemeSelector = false
    
    var body: some View {
        NavigationView {
            List {
                // Theme Section
                Section(header: Text("Appearance").foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))) {
                    HStack {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Theme")
                                .foregroundColor(themeManager.currentTheme.textColor)
                            Text(themeManager.currentTheme.rawValue)
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingThemeSelector = true
                        }) {
                            Text("Change")
                                .foregroundColor(themeManager.currentTheme.accentColor)
                        }
                    }
                }
                
                // About Section
                Section(header: Text("About").foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Version")
                                .foregroundColor(themeManager.currentTheme.textColor)
                            Text("1.0.0")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "mountain.2.fill")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Whistler Blackcomb")
                                .foregroundColor(themeManager.currentTheme.textColor)
                            Text("Official mountain data")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.textColor.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                }
                
                // Support Section
                Section(header: Text("Support").foregroundColor(themeManager.currentTheme.textColor.opacity(0.6))) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .frame(width: 24)
                        
                        Text("Contact Support")
                            .foregroundColor(themeManager.currentTheme.textColor)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.5))
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .frame(width: 24)
                        
                        Text("Rate App")
                            .foregroundColor(themeManager.currentTheme.textColor)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.textColor.opacity(0.5))
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(themeManager.currentTheme.backgroundColor)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingThemeSelector) {
                ThemeSelectorView(themeManager: themeManager)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
} 