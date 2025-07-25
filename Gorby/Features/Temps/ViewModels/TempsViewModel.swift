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
    
    private let weatherService = WeatherKitService.shared
    
    init() {
        Task {
            await loadWeatherData()
        }
    }
    
    func loadWeatherData() async {
        isLoading = true
        errorMessage = nil
        
        let stations = await weatherService.fetchAllTemperatureStations()
        temperatureStations = stations
        
        let realDataCount = stations.filter { $0.lastUpdated == "Just now" }.count
        let errorCount = stations.filter { $0.lastUpdated == "Error fetching data" }.count
        
        if realDataCount > 0 {
            print("✅ Successfully loaded \(realDataCount) real WeatherKit stations")
        }
        if errorCount > 0 {
            print("❌ \(errorCount) stations failed to load (WeatherKit authentication error)")
            if errorCount == stations.count {
                errorMessage = "WeatherKit access denied. Check entitlements and Apple Developer account."
            }
        }
        
        isLoading = false
    }
    
    func refreshData() async {
        await loadWeatherData()
    }
} 