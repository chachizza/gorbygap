//
//  ForecastViewModel.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import WeatherKit

@MainActor
class ForecastViewModel: ObservableObject {
    @Published var forecast: [DayForecast] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentConditions: CurrentConditions?
    
    private let weatherService = WeatherKitService.shared
    
    init() {
        Task {
            await loadForecast()
        }
    }
    
    func loadForecast() async {
        isLoading = true
        errorMessage = nil
        
        let forecastData = await weatherService.fetchWeatherForecast()
        forecast = forecastData
        
        // TODO: Load real current conditions when API is available
        // For now, show empty state - no mock data
        currentConditions = nil
        
        isLoading = false
    }
    
    func refreshData() async {
        await loadForecast()
    }
    
    func refreshForecast() async {
        await loadForecast()
    }
}
