//
//  HomeView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with theme toggle
                    HStack {
                        Image(themeManager.currentTheme == .light ? "logo-dark" : "logo-light")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                        
                        Spacer()
                        
                        ThemeToggleButton(themeManager: themeManager)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // New Snow Alert Banner with animated gradient
                    AnimatedNewSnowBanner(snowAmount: viewModel.newSnowAmount, themeManager: themeManager)
                        .padding(.horizontal, 20)
                    
                    // Live Temps Round Icons (no background, no margins)
                    LiveTempsRoundIcons()
                    
                    // All Action Buttons (6 total)
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        NavigationLink(destination: ForecastView()) {
                            AnimatedActionCard(
                                icon: "cloud.snow",
                                title: "FORECAST",
                                colors: getStationColors(for: "7TH HEAVEN"),
                                themeManager: themeManager
                            )
                        }
                        
                        NavigationLink(destination: TempsView()) {
                            AnimatedActionCard(
                                icon: "thermometer",
                                title: "TEMPS",
                                colors: getStationColors(for: "RENDEZVOUS"),
                                themeManager: themeManager
                            )
                        }
                        
                        NavigationLink(destination: LiftStatusView()) {
                            AnimatedActionCard(
                                icon: "arrow.up.circle.fill",
                                title: "LIFTS",
                                colors: getStationColors(for: "ROUNDHOUSE"),
                                themeManager: themeManager
                            )
                        }
                        
                        NavigationLink(destination: WebcamView()) {
                            AnimatedActionCard(
                                icon: "video.fill",
                                title: "WEBCAMS",
                                colors: getDarkPinkGradient(),
                                themeManager: themeManager
                            )
                        }
                        
                        NavigationLink(destination: SnowStakeView()) {
                            AnimatedActionCard(
                                icon: "ruler.fill",
                                title: "SNOW STAKE",
                                colors: getStationColors(for: "VILLAGE"),
                                themeManager: themeManager
                            )
                        }
                        
                        NavigationLink(destination: ApresKsiView()) {
                            AnimatedActionCard(
                                icon: "fork.knife",
                                title: "APRES",
                                colors: getGreenGradient(),
                                themeManager: themeManager
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Instagram Feed Section
                    InstagramFeedSection(themeManager: themeManager, posts: viewModel.instagramPosts, error: viewModel.instagramError, viewModel: viewModel)
                        .padding(.bottom, 20)
                }
            }
            .background(themeManager.currentTheme.backgroundColor)
            .navigationBarHidden(true)
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }
    
    private func getStationColors(for stationName: String) -> [Color] {
        switch themeManager.currentTheme {
        case .light, .dark:
            return getOriginalStationColors(for: stationName)
        case .greyscale:
            return [Color(red: 0.4, green: 0.4, blue: 0.4), Color(red: 0.6, green: 0.6, blue: 0.6)]
        }
    }
    
    private func getOriginalStationColors(for stationName: String) -> [Color] {
        switch stationName {
        case "PEAK":
            return [Color(red: 1.0, green: 0.2, blue: 0.8), Color(red: 0.9, green: 0.1, blue: 0.7)] // Bright pink/magenta
        case "7TH HEAVEN":
            return [Color(red: 0.6, green: 0.2, blue: 1.0), Color(red: 0.8, green: 0.4, blue: 1.0)] // Purple
        case "ROUNDHOUSE":
            return [Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 1.0, green: 0.7, blue: 0.2)] // Orange
        case "RENDEZVOUS":
            return [Color(red: 0.0, green: 0.7, blue: 0.8), Color(red: 0.1, green: 0.9, blue: 1.0)] // Turquoise
        case "MIDSTATION":
            return [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.1, green: 0.6, blue: 0.3)] // Green
        case "VILLAGE":
            return [Color(red: 1.0, green: 0.4, blue: 0.8), Color(red: 1.0, green: 0.6, blue: 0.9)] // Lighter pink
        default:
            return [Color(red: 0.6, green: 0.2, blue: 1.0), Color(red: 0.8, green: 0.4, blue: 1.0)] // Default purple
        }
    }
    
    private func getDarkPinkGradient() -> [Color] {
        switch themeManager.currentTheme {
        case .light, .dark:
            return [Color(red: 1.0, green: 0.2, blue: 0.8), Color(red: 0.9, green: 0.1, blue: 0.7)] // Bright pink/magenta gradient
        case .greyscale:
            return [Color(red: 0.4, green: 0.4, blue: 0.4), Color(red: 0.6, green: 0.6, blue: 0.6)]
        }
    }
    
    private func getGreenGradient() -> [Color] {
        switch themeManager.currentTheme {
        case .light, .dark:
            return [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.1, green: 0.6, blue: 0.3)] // Green gradient
        case .greyscale:
            return [Color(red: 0.4, green: 0.4, blue: 0.4), Color(red: 0.6, green: 0.6, blue: 0.6)]
        }
    }
    
    private func getDeepPurpleGradient() -> [Color] {
        switch themeManager.currentTheme {
        case .light, .dark:
            return [Color(red: 0.4, green: 0.1, blue: 0.8), Color(red: 0.6, green: 0.2, blue: 1.0)] // Deep purple gradient
        case .greyscale:
            return [Color(red: 0.4, green: 0.4, blue: 0.4), Color(red: 0.6, green: 0.6, blue: 0.6)]
        }
    }
    
    private func getRedGradient() -> [Color] {
        switch themeManager.currentTheme {
        case .light, .dark:
            return [Color(red: 0.8, green: 0.2, blue: 0.4), Color(red: 0.9, green: 0.3, blue: 0.5)] // Red gradient
        case .greyscale:
            return [Color(red: 0.4, green: 0.4, blue: 0.4), Color(red: 0.6, green: 0.6, blue: 0.6)]
        }
    }
}

struct LiveTempsRoundIcons: View {
    @StateObject private var tempsViewModel = TempsViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(tempsViewModel.temperatureStations) { station in
                    RoundTempIcon(station: station, themeManager: themeManager)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct RoundTempIcon: View {
    let station: TemperatureStation
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: stationColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 90, height: 90)
                .overlay(
                    Text("\(Int(station.temperature))°")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            Text(station.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(themeManager.currentTheme.textColor)
                .multilineTextAlignment(.center)
        }
    }
    
    private var stationColors: [Color] {
        switch themeManager.currentTheme {
        case .light, .dark:
            return getOriginalStationColors(for: station.name)
        case .greyscale:
            return [Color(red: 0.4, green: 0.4, blue: 0.4), Color(red: 0.6, green: 0.6, blue: 0.6)]
        }
    }
    
    private func getOriginalStationColors(for stationName: String) -> [Color] {
        switch stationName {
        case "PEAK":
            return [Color(red: 1.0, green: 0.2, blue: 0.8), Color(red: 0.9, green: 0.1, blue: 0.7)] // Dark pink
        case "7TH HEAVEN":
            return [Color(red: 0.6, green: 0.2, blue: 1.0), Color(red: 0.8, green: 0.4, blue: 1.0)] // Purple
        case "ROUNDHOUSE":
            return [Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 1.0, green: 0.7, blue: 0.2)] // Orange
        case "RENDEZVOUS":
            return [Color(red: 0.0, green: 0.7, blue: 0.8), Color(red: 0.1, green: 0.9, blue: 1.0)] // Turquoise
        case "MIDSTATION":
            return [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.1, green: 0.6, blue: 0.3)] // Green
        case "VILLAGE":
            return [Color(red: 1.0, green: 0.4, blue: 0.8), Color(red: 1.0, green: 0.6, blue: 0.9)] // Lighter pink
        default:
            return [Color(red: 0.6, green: 0.2, blue: 1.0), Color(red: 0.8, green: 0.4, blue: 1.0)] // Default purple
        }
    }
}

struct InstagramFeedSection: View {
    @ObservedObject var themeManager: ThemeManager
    let posts: [InstagramPost]
    let error: String?
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "camera.fill")
                    .font(.title3)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                
                Text("#gorbygap")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            if posts.isEmpty {
                VStack(spacing: 8) {
                    if let error = error {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text("Failed to load Instagram posts")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(error)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                // Show token status for debugging
                                Text(viewModel.instagramTokenStatus)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                                    .opacity(0) // Hidden but code preserved
                                
                                // Manual refresh button for debugging
                                Button("Refresh Token") {
                                    Task {
                                        await viewModel.refreshInstagramToken()
                                        await viewModel.loadInstagramPosts()
                                    }
                                }
                                .font(.caption2)
                                .padding(.top, 4)
                            }
                            Spacer()
                        }
                    } else if viewModel.isLoadingInstagram {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Loading Instagram posts...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                // Show token status while loading
                                Text(viewModel.instagramTokenStatus)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                                    .opacity(0) // Hidden but code preserved
                            }
                            Spacer()
                        }
                    } else {
                        // Empty state - encourage users to post
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                Image(systemName: "camera.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(themeManager.currentTheme.accentColor)
                                
                                VStack(spacing: 6) {
                                    Text("Be the first to share!")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(themeManager.currentTheme.textColor)
                                    
                                    Text("Use the hashtag")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("#gorbygap")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(themeManager.currentTheme.accentColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(themeManager.currentTheme.accentColor.opacity(0.1))
                                        )
                                    
                                    Text("to be featured here!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                // Show token status for debugging
                                Text(viewModel.instagramTokenStatus)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
                                    .opacity(0) // Hidden but code preserved
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(posts) { post in
                                InstagramPostCard(post: post, themeManager: themeManager)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Show token status at bottom for debugging (can be removed later)
                    Text(viewModel.instagramTokenStatus)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .opacity(0) // Hidden but code preserved
                }
            }
        }
    }
}

struct InstagramPostCard: View {
    let post: InstagramPost
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        // Clean image-only layout
        AsyncImage(url: URL(string: post.imageUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 140, height: 140)
                .clipped()
                .cornerRadius(12)
        } placeholder: {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: postGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)
                .overlay(
                    ProgressView()
                        .foregroundColor(.white)
                )
        }
        .frame(width: 140)
        .onTapGesture {
            if let url = URL(string: post.permalink) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private var postGradientColors: [Color] {
        switch themeManager.currentTheme {
        case .light, .dark:
            return [
                Color(red: 0.0, green: 0.8, blue: 0.8),
                Color(red: 0.6, green: 0.2, blue: 1.0)
            ]
        case .greyscale:
            return [
                Color(red: 0.4, green: 0.4, blue: 0.4),
                Color(red: 0.6, green: 0.6, blue: 0.6)
            ]
        }
    }
}

struct AnimatedNewSnowBanner: View {
    let snowAmount: Int
    @ObservedObject var themeManager: ThemeManager
    @State private var animationOffset: CGFloat = 0
    @State private var currentWeatherIcon: String = "sun.max"
    @State private var currentWeatherCondition: String = "Sunny"
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("New Snow")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                
                Text("\(snowAmount) cm")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Weather Status Icon
            VStack(spacing: 4) {
                Image(systemName: currentWeatherIcon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(currentWeatherCondition)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 80)
            }
            .frame(width: 80)
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(Date().formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(Date().formatted(date: .omitted, time: .shortened))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: animatedColors,
                startPoint: UnitPoint(x: 0.0 + animationOffset * 0.3, y: 0.0),
                endPoint: UnitPoint(x: 1.0 + animationOffset * 0.3, y: 1.0)
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onAppear {
            loadCurrentWeather()
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: true)) {
                animationOffset = 1.0
            }
        }
    }
    
    private func loadCurrentWeather() {
        Task {
            let forecast = await WeatherKitService.shared.fetchWeatherForecast()
            if let todayForecast = forecast.first {
                await MainActor.run {
                    currentWeatherIcon = todayForecast.iconName
                    currentWeatherCondition = todayForecast.condition
                }
            } else {
                // Fallback to default sunny weather
                await MainActor.run {
                    currentWeatherIcon = "sun.max"
                    currentWeatherCondition = "Sunny"
                }
            }
        }
    }
    
    private var animatedColors: [Color] {
        switch themeManager.currentTheme {
        case .light, .dark:
            return [
                Color(red: 0.2, green: 0.1, blue: 0.6), // Dark blueish purple
                Color(red: 0.4, green: 0.2, blue: 0.8)  // Lighter blueish purple
            ]
        case .greyscale:
            return [
                Color(red: 0.3, green: 0.3, blue: 0.3), // Dark gray
                Color(red: 0.5, green: 0.5, blue: 0.5)  // Light gray
            ]
        }
    }
}

struct AnimatedActionCard: View {
    let icon: String
    let title: String
    let colors: [Color]
    @ObservedObject var themeManager: ThemeManager
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.white)
                .rotationEffect(.degrees(icon == "ruler.fill" ? 90 : 0))
                .frame(height: 40)
            
            Spacer()
                .frame(height: 8)
            
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(color: colors.first?.opacity(0.3) ?? .black.opacity(0.1), radius: 6, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        isPressed = false
                    }
                }
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(ThemeManager())
} 
