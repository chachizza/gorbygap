//
//  TempsView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import SwiftUI

struct TempsView: View {
    @StateObject private var viewModel = TempsViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading temperatures...")
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                await viewModel.refreshData()
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(viewModel.temperatureStations) { station in
                                    TemperatureStationCard(station: station)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                        .padding(.top, 8)
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Temps")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }
}

struct TemperatureStationCard: View {
    let station: TemperatureStation
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text(station.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: themeManager.currentTheme == .greyscale ? 
                                [Color.gray.opacity(0.2), Color.gray.opacity(0.4)] : 
                                [darkerStationColors.1, darkerStationColors.1.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: themeManager.currentTheme == .greyscale ? 
                                [Color.gray.opacity(0.4), Color.gray.opacity(0.6)] : 
                                [stationColors.0, stationColors.1],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 6
                    )
                    .frame(width: 110, height: 110)
                
                VStack(spacing: 4) {
                    Text("\(Int(station.temperature))°")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(station.windSpeed) km/h")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: themeManager.currentTheme == .greyscale ? 
                            [Color.gray.opacity(0.3), Color.gray.opacity(0.5)] : 
                            [stationColors.0, stationColors.1],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: themeManager.currentTheme == .greyscale ? 
                        Color.gray.opacity(0.3) : stationColors.0.opacity(0.4), 
                        radius: 8, x: 0, y: 4)
        )
    }
    
    private var stationColors: (Color, Color) {
        switch station.name {
        case "PEAK":
            return (Color(red: 1.0, green: 0.2, blue: 0.8), Color(red: 0.9, green: 0.1, blue: 0.7)) // Bright pink/magenta
        case "7TH HEAVEN":
            return (Color(red: 0.6, green: 0.2, blue: 1.0), Color(red: 0.8, green: 0.4, blue: 1.0)) // Purple
        case "ROUNDHOUSE":
            return (Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 1.0, green: 0.7, blue: 0.2)) // Orange
        case "RENDEZVOUS":
            return (Color(red: 0.0, green: 0.7, blue: 0.8), Color(red: 0.1, green: 0.9, blue: 1.0)) // Turquoise
        case "MIDSTATION":
            return (Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.1, green: 0.6, blue: 0.3)) // Green
        case "VILLAGE":
            return (Color(red: 1.0, green: 0.4, blue: 0.8), Color(red: 1.0, green: 0.6, blue: 0.9)) // Lighter pink
        default:
            return (Color(red: 0.6, green: 0.2, blue: 1.0), Color(red: 0.8, green: 0.4, blue: 1.0)) // Default purple
        }
    }
    
    private var darkerStationColors: (Color, Color) {
        switch station.name {
        case "PEAK":
            return (Color(red: 0.5, green: 0.1, blue: 0.4), Color(red: 0.45, green: 0.05, blue: 0.35)) // Darker bright pink/magenta
        case "7TH HEAVEN":
            return (Color(red: 0.3, green: 0.1, blue: 0.5), Color(red: 0.4, green: 0.2, blue: 0.6)) // Darker purple
        case "ROUNDHOUSE":
            return (Color(red: 0.5, green: 0.25, blue: 0.0), Color(red: 0.6, green: 0.35, blue: 0.1)) // Darker orange
        case "RENDEZVOUS":
            return (Color(red: 0.0, green: 0.35, blue: 0.4), Color(red: 0.05, green: 0.45, blue: 0.5)) // Darker turquoise
        case "MIDSTATION":
            return (Color(red: 0.1, green: 0.4, blue: 0.2), Color(red: 0.05, green: 0.3, blue: 0.15)) // Darker green
        case "VILLAGE":
            return (Color(red: 0.5, green: 0.2, blue: 0.4), Color(red: 0.6, green: 0.3, blue: 0.5)) // Darker lighter pink
        default:
            return (Color(red: 0.3, green: 0.1, blue: 0.5), Color(red: 0.4, green: 0.2, blue: 0.6)) // Default darker purple
        }
    }
}

// Note: Supporting data structures are now in Models/TemperatureData.swift

#Preview {
    TempsView()
} 