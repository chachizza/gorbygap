//
//  WhistlerRideTabView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import SwiftUI

struct WhistlerRideTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingThemeSelector = false
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            LiftStatusView()
                .tabItem {
                    Image(systemName: "arrow.up.circle.fill")
                    Text("Lifts")
                }
            
            WebcamView()
                .tabItem {
                    Image(systemName: "video.fill")
                    Text("Webcams")
                }
            
            ForecastView()
                .tabItem {
                    Image(systemName: "cloud.snow.fill")
                    Text("Forecast")
                }
            
            MoreView()
                .tabItem {
                    Image(systemName: "ellipsis")
                    Text("More")
                }
        }
        .accentColor(themeManager.currentTheme.accentColor)
        .background(themeManager.currentTheme.backgroundColor)
        .sheet(isPresented: $showingThemeSelector) {
            ThemeSelectorView(themeManager: themeManager)
        }
    }
}

struct ThemeToggleButton: View {
    @ObservedObject var themeManager: ThemeManager
    @State private var showingThemeSelector = false
    
    var body: some View {
        Button(action: {
            showingThemeSelector = true
        }) {
            Image(systemName: themeManager.currentTheme.iconName)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.currentTheme.secondaryAccentColor,
                                    themeManager.currentTheme.accentColor
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: themeManager.currentTheme.accentColor.opacity(0.4), radius: 6, x: 0, y: 3)
                )
        }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: themeManager.currentTheme)
        .sheet(isPresented: $showingThemeSelector) {
            ThemeSelectorView(themeManager: themeManager)
        }
    }
}

struct MoreView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: TempsView()) {
                    HStack {
                        Image(systemName: "thermometer")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .frame(width: 24)
                        Text("Temps")
                        Spacer()
                    }
                }
                
                NavigationLink(destination: ApresKsiView()) {
                    HStack {
                        Image(systemName: "fork.knife")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .frame(width: 24)
                        Text("Apres")
                        Spacer()
                    }
                }
                
                NavigationLink(destination: SnowStakeView()) {
                    HStack {
                        Image(systemName: "ruler.fill")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .frame(width: 24)
                        Text("Snow Stake")
                        Spacer()
                    }
                }
                
                NavigationLink(destination: SettingsView()) {
                    HStack {
                        Image(systemName: "gear")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .frame(width: 24)
                        Text("Settings")
                        Spacer()
                    }
                }
            }
            .navigationTitle("More")
            .background(themeManager.currentTheme.backgroundColor)
        }
    }
}

#Preview {
    WhistlerRideTabView()
        .environmentObject(ThemeManager())
} 