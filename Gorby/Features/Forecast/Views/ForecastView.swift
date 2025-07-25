//
//  ForecastView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import SwiftUI

struct ForecastView: View {
    @StateObject private var viewModel = ForecastViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading forecast...")
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
                                await viewModel.refreshForecast()
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // 5-Day Forecast
                            VStack(alignment: .leading, spacing: 12) {
                                Text("5-Day Alpine Forecast")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                
                                ForEach(viewModel.forecast) { day in
                                    ForecastDayCard(forecast: day)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Forecast")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.refreshForecast()
            }
        }
    }
}

struct ForecastDayCard: View {
    let forecast: DayForecast
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Date
            VStack {
                Text(forecast.dayOfWeek)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                
                Text(forecast.date)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(width: 60)
            
            // Weather Icon & Condition
            VStack(spacing: 4) {
                Image(systemName: forecast.iconName)
                    .font(.title3)
                    .foregroundColor(.white)
                
                Text(forecast.condition.replacingOccurrences(of: " ", with: "\n"))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 80)
            
            // Temperature Range
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("High:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(forecast.highTemp)°C")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Low:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(forecast.lowTemp)°C")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            // Snow Forecast
            VStack(alignment: .trailing, spacing: 2) {
                if forecast.snowfall > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "snow")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Text("\(forecast.snowfall) cm")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("\(forecast.precipitationChance)% chance")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text("No snow")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 16)
        .padding(.vertical, 26)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: cardColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: cardColors.first?.opacity(0.4) ?? .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    

    private var cardColors: [Color] {
        if themeManager.currentTheme == .greyscale {
            return [Color.gray.opacity(0.3), Color.gray.opacity(0.5)]
        }
        
        switch forecast.dayOfWeek {
        case "Today":
            return [Color(red: 0.6, green: 0.2, blue: 1.0), Color(red: 0.8, green: 0.4, blue: 1.0)] // Purple (FORECAST)
        case "Tomorrow":
            return [Color(red: 1.0, green: 0.2, blue: 0.8), Color(red: 0.9, green: 0.1, blue: 0.7)] // Bright Pink (WEBCAMS)
        case "Sun":
            return [Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 1.0, green: 0.7, blue: 0.2)] // Orange (LIFTS)
        case "Mon":
            return [Color(red: 0.0, green: 0.7, blue: 0.8), Color(red: 0.1, green: 0.9, blue: 1.0)] // Turquoise (TEMPS)
        case "Tue":
            return [Color(red: 1.0, green: 0.4, blue: 0.8), Color(red: 1.0, green: 0.6, blue: 0.9)] // Pink (APRES)
        case "Wed":
            return [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.1, green: 0.6, blue: 0.3)] // Green (SNOW STAKE)
        case "Thu":
            return [Color(red: 0.8, green: 0.2, blue: 0.4), Color(red: 0.9, green: 0.3, blue: 0.5)] // Red
        case "Fri":
            return [Color(red: 0.4, green: 0.1, blue: 0.8), Color(red: 0.6, green: 0.2, blue: 1.0)] // Deep Purple
        case "Sat":
            return [Color(red: 1.0, green: 0.7, blue: 0.0), Color(red: 1.0, green: 0.85, blue: 0.2)] // Yellow
        default:
            return [Color(red: 0.5, green: 0.5, blue: 0.5), Color(red: 0.7, green: 0.7, blue: 0.7)] // Gray
        }
    }
}

#Preview {
    ForecastView()
} 