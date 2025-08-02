//
//  TempsViewModel.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import SwiftUI

@MainActor
class TempsViewModel: ObservableObject {
    @Published var temperatureStations: [TemperatureStation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingRetryButton = false
    
    private let weatherService = WeatherKitService.shared
    private let errorHandler = ErrorHandlingService.shared
    
    init() {
        Task {
            await loadWeatherData()
        }
    }
    
    func loadWeatherData() async {
        isLoading = true
        errorMessage = nil
        showingRetryButton = false
        
        let stations = await weatherService.fetchAllTemperatureStations()
        temperatureStations = stations
        
        let realDataCount = stations.filter { $0.lastUpdated == "Just now" }.count
        let errorCount = stations.filter { $0.lastUpdated == "Error fetching data" }.count
        
        if realDataCount > 0 {
            print("✅ Successfully loaded \(realDataCount) real WeatherKit stations")
            errorMessage = nil
        }
        
        if errorCount > 0 {
            print("❌ \(errorCount) stations failed to load")
            
            if errorCount == stations.count {
                // Complete failure
                let error = AppError(
                    category: .weather,
                    title: "Weather Data Unavailable",
                    message: "Unable to access weather information",
                    context: "All temperature stations failed",
                    suggestion: "Check your internet connection and try again. If the problem persists, weather services may be temporarily unavailable.",
                    isRetryable: true
                )
                
                errorMessage = error.message
                showingRetryButton = true
                errorHandler.handleError(error, context: "Loading all temperature data", showToUser: true)
                
            } else {
                // Partial failure
                errorMessage = "Some weather data couldn't be loaded (\(errorCount) of \(stations.count) stations)"
                showingRetryButton = true
            }
        }
        
        isLoading = false
    }
    
    func refreshData() async {
        await loadWeatherData()
    }
    
    /// Retry loading with haptic feedback
    func retryWithFeedback() async {
        // Provide haptic feedback for retry action
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        await loadWeatherData()
    }
}
