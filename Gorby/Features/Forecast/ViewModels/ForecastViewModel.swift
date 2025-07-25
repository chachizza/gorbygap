//
//  ForecastViewModel.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import WeatherKit
import CoreLocation
import SwiftUI

@MainActor
class ForecastViewModel: ObservableObject {
    @Published var forecast: [DayForecast] = []
    @Published var currentConditions: CurrentConditions = CurrentConditions.mock
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let weatherService = WeatherKitService.shared
    
    init() {
        Task {
            await loadWeatherData()
        }
    }
    
    func loadWeatherData() async {
        isLoading = true
        errorMessage = nil
        
        let forecastData = await weatherService.fetchWeatherForecast()
        forecast = forecastData
        
        // Check if we got real data or error data
        if !forecastData.isEmpty {
            if forecastData.first?.dayOfWeek == "Error" {
                print("❌ Forecast failed to load (WeatherKit authentication error)")
                errorMessage = "WeatherKit access denied. Check entitlements and Apple Developer account."
            } else {
                print("✅ Successfully loaded real WeatherKit forecast")
            }
        }
        
        isLoading = false
    }
    
    func refreshForecast() async {
        await loadWeatherData()
    }
} 