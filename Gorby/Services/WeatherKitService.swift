//
//  WeatherKitService.swift
//  Gorby
//
//  Created by Mark T on 2025-07-18.
//

import Foundation
import WeatherKit
import CoreLocation
import SwiftUI

@MainActor
class WeatherKitService {
    static let shared = WeatherKitService()
    
    private let weatherService: WeatherService
    
    // Whistler Mountain Locations with Real Coordinates
    let whistlerLocations: [(name: String, location: CLLocation, color: Color)] = [
        ("PEAK", CLLocation(latitude: 50.0597, longitude: -122.9486), Color(red: 0.8, green: 0.2, blue: 0.4)), // Whistler Peak (2182m)
        ("7TH HEAVEN", CLLocation(latitude: 50.0597, longitude: -122.8820), Color(red: 0.6, green: 0.2, blue: 1.0)), // Blackcomb Peak (2284m)
        ("ROUNDHOUSE", CLLocation(latitude: 50.0647, longitude: -122.9491), Color(red: 1.0, green: 0.5, blue: 0.0)), // Roundhouse (1850m)
        ("RENDEZVOUS", CLLocation(latitude: 50.0739, longitude: -122.8744), Color(red: 0.0, green: 0.7, blue: 0.8)), // Rendezvous (1860m)
        ("MIDSTATION", CLLocation(latitude: 50.0867, longitude: -122.9445), Color(red: 1.0, green: 0.7, blue: 0.0)), // Whistler Mid (1300m)
        ("VILLAGE", CLLocation(latitude: 50.1163, longitude: -122.9574), Color(red: 1.0, green: 0.4, blue: 0.8)) // Village (675m)
    ]
    
    private init() {
        self.weatherService = WeatherService()
        print("🏔️ WeatherKitService initialized successfully")
        
        // Test basic WeatherKit availability
        Task {
            await checkWeatherKitAvailability()
        }
    }
    
    /// Test if WeatherKit is available and working
    private func checkWeatherKitAvailability() async {
        print("🔍 Testing WeatherKit availability...")
        
        // Check if we're running in simulator
        #if targetEnvironment(simulator)
        print("📱 Running in iOS Simulator - WeatherKit will not work")
        print("💡 Using realistic test data for simulator")
        #else
        print("📱 Running on real device - attempting WeatherKit")
        
        let testLocation = CLLocation(latitude: 50.1163, longitude: -122.9574) // Whistler Village
        
        do {
            let _ = try await weatherService.weather(for: testLocation)
            print("✅ WeatherKit is available and working!")
        } catch {
            print("❌ WeatherKit availability test failed:")
            print("❌ Error: \(error)")
            print("❌ Error type: \(type(of: error))")
            
            if let nsError = error as NSError? {
                print("❌ Domain: \(nsError.domain)")
                print("❌ Code: \(nsError.code)")
                print("❌ UserInfo: \(nsError.userInfo)")
            }
            
            // Common WeatherKit issues
            if error.localizedDescription.contains("not available") {
                print("💡 WeatherKit not available - likely due to simulator or entitlement issues")
            } else if error.localizedDescription.contains("authentication") {
                print("💡 WeatherKit authentication failed - check Apple Developer account and entitlements")
            } else {
                print("💡 Unknown WeatherKit error - check network connectivity and location")
            }
        }
        #endif
    }
    
    /// Check if running in simulator
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// Fetch real weather data from Apple WeatherKit
    func weather(for location: CLLocation) async throws -> Weather {
        do {
            return try await weatherService.weather(for: location)
        } catch {
            print("❌ WeatherKit request failed: \(error)")
            throw WeatherError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// Fetch current weather for all Whistler locations
    func fetchAllTemperatureStations() async -> [TemperatureStation] {
        var stations: [TemperatureStation] = []
        
        print("🌤️ Fetching weather data...")
        
        // Use realistic test data in simulator
        if isSimulator {
            print("📱 Simulator detected - using realistic test data")
            return createRealisticTestStations()
        }
        
        print("📱 Real device detected - using WeatherKit")
        
        for location in whistlerLocations {
            print("📍 Attempting to fetch weather for \(location.name) at \(location.location.coordinate)")
            
            do {
                // Try the simplest possible WeatherKit call first
                let weather = try await weatherService.weather(for: location.location)
                print("🎯 Got weather object for \(location.name)")
                
                let station = mapWeatherToTemperatureStation(
                    current: weather.currentWeather,
                    name: location.name,
                    color: location.color
                )
                stations.append(station)
                print("✅ Fetched real weather for \(location.name): \(station.temperature)°C")
            } catch {
                print("❌ Failed to fetch weather for \(location.name)")
                print("❌ Error details: \(error)")
                print("❌ Error type: \(type(of: error))")
                if let nsError = error as NSError? {
                    print("❌ Error domain: \(nsError.domain)")
                    print("❌ Error code: \(nsError.code)")
                    print("❌ Error userInfo: \(nsError.userInfo)")
                }
                // Show clear error state instead of mock data
                stations.append(createErrorStation(name: location.name, color: location.color))
            }
        }
        
        return stations
    }
    
    /// Fetch 5-day forecast for Whistler Village
    func fetchWeatherForecast() async -> [DayForecast] {
        print("📍 Attempting to fetch forecast...")
        
        // Use realistic test data in simulator
        if isSimulator {
            print("📱 Simulator detected - using realistic test forecast")
            return createRealisticTestForecast()
        }
        
        print("📱 Real device detected - using WeatherKit")
        let location = CLLocation(latitude: 50.1163, longitude: -122.9574) // Whistler Village
        
        do {
            // Try the simplest possible forecast call
            let weather = try await weatherService.weather(for: location)
            print("🎯 Got weather object for forecast")
            
            // Convert Forecast<DayWeather> to [DayWeather]
            let dailyWeatherArray = Array(weather.dailyForecast)
            let forecastData = mapToForecast(weather: dailyWeatherArray)
            print("✅ Fetched real forecast data: \(forecastData.count) days")
            return forecastData
        } catch {
            print("❌ Failed to fetch real forecast")
            print("❌ Forecast error details: \(error)")
            if let nsError = error as NSError? {
                print("❌ Forecast error domain: \(nsError.domain)")
                print("❌ Forecast error code: \(nsError.code)")
            }
            return createErrorForecast()
        }
    }
    
    // MARK: - Private Methods
    
    private func mapWeatherToTemperatureStation(current: CurrentWeather, name: String, color: Color) -> TemperatureStation {
        let temperature = current.temperature.value
        let windSpeed = current.wind.speed.value * 3.6 // Convert m/s to km/h
        
        return TemperatureStation(
            name: name,
            temperature: temperature,
            windSpeed: Int(windSpeed),
            color: color,
            lastUpdated: "Just now"
        )
    }
    
    private func mapToForecast(weather: [DayWeather]) -> [DayForecast] {
        var forecastDays: [DayForecast] = []
        
        for (index, dayWeather) in weather.prefix(5).enumerated() {
            let dayName = index == 0 ? "Today" : 
                         index == 1 ? "Tomorrow" : 
                         DateFormatter.dayFormatter.string(from: dayWeather.date)
            
            let forecast = DayForecast(
                dayOfWeek: dayName,
                date: DateFormatter.dateFormatter.string(from: dayWeather.date),
                condition: mapCondition(dayWeather.condition),
                iconName: mapIconName(dayWeather.condition),
                highTemp: Int(dayWeather.highTemperature.value),
                lowTemp: Int(dayWeather.lowTemperature.value),
                snowfall: 0, // Summer season
                precipitationChance: Int(dayWeather.precipitationChance * 100)
            )
            forecastDays.append(forecast)
        }
        
        return forecastDays
    }
    
    private func mapCondition(_ condition: WeatherCondition) -> String {
        switch condition {
        case .clear:
            return "Sunny"
        case .partlyCloudy:
            return "Partly Cloudy"
        case .cloudy:
            return "Cloudy"
        case .mostlyCloudy:
            return "Mostly Cloudy"
        case .drizzle:
            return "Light Rain"
        case .rain:
            return "Rain"
        case .heavyRain:
            return "Heavy Rain"
        case .snow:
            return "Snow"
        case .heavySnow:
            return "Heavy Snow"
        case .sleet:
            return "Sleet"
        case .hail:
            return "Hail"
        default:
            return "Mixed Conditions"
        }
    }
    
    private func mapIconName(_ condition: WeatherCondition) -> String {
        switch condition {
        case .clear:
            return "sun.max"
        case .partlyCloudy:
            return "cloud.sun"
        case .cloudy, .mostlyCloudy:
            return "cloud"
        case .drizzle:
            return "cloud.drizzle"
        case .rain:
            return "cloud.rain"
        case .heavyRain:
            return "cloud.heavyrain"
        case .snow:
            return "cloud.snow"
        case .heavySnow:
            return "cloud.snow.fill"
        case .sleet:
            return "cloud.sleet"
        case .hail:
            return "cloud.hail"
        default:
            return "cloud"
        }
    }
    
    // MARK: - Fallback Methods (only used if WeatherKit fails)
    
    private func createErrorStation(name: String, color: Color) -> TemperatureStation {
        return TemperatureStation(
            name: name,
            temperature: 0.0,
            windSpeed: 0,
            color: color,
            lastUpdated: "Error fetching data"
        )
    }
    
    private func createErrorForecast() -> [DayForecast] {
        return [
            DayForecast(
                dayOfWeek: "Error",
                date: DateFormatter.dateFormatter.string(from: Date()),
                condition: "Error",
                iconName: "exclamationmark.triangle",
                highTemp: 0,
                lowTemp: 0,
                snowfall: 0,
                precipitationChance: 0
            )
        ]
    }
    
    // MARK: - Realistic Test Data (for simulator)
    
    private func createRealisticTestStations() -> [TemperatureStation] {
        var stations: [TemperatureStation] = []
        
        for location in whistlerLocations {
            let temperature = Double.random(in: 10...25) // Random temperature
            let windSpeed = Int.random(in: 5...20) // Random wind speed
            
            stations.append(TemperatureStation(
                name: location.name,
                temperature: temperature,
                windSpeed: windSpeed,
                color: location.color,
                lastUpdated: "Just now"
            ))
        }
        return stations
    }
    
    private func createRealisticTestForecast() -> [DayForecast] {
        let forecastDays: [DayForecast] = [
            DayForecast(
                dayOfWeek: "Today",
                date: DateFormatter.dateFormatter.string(from: Date()),
                condition: "Sunny",
                iconName: "sun.max",
                highTemp: Int.random(in: 15...25),
                lowTemp: Int.random(in: 5...10),
                snowfall: 0,
                precipitationChance: 0
            ),
            DayForecast(
                dayOfWeek: "Tomorrow",
                date: DateFormatter.dateFormatter.string(from: Date().addingTimeInterval(86400)),
                condition: "Partly Cloudy",
                iconName: "cloud.sun",
                highTemp: Int.random(in: 12...18),
                lowTemp: Int.random(in: 2...8),
                snowfall: 0,
                precipitationChance: 20
            ),
            DayForecast(
                dayOfWeek: DateFormatter.dayFormatter.string(from: Date().addingTimeInterval(172800)),
                date: DateFormatter.dateFormatter.string(from: Date().addingTimeInterval(172800)),
                condition: "Cloudy",
                iconName: "cloud",
                highTemp: Int.random(in: 10...15),
                lowTemp: Int.random(in: 0...5),
                snowfall: 0,
                precipitationChance: 50
            ),
            DayForecast(
                dayOfWeek: DateFormatter.dayFormatter.string(from: Date().addingTimeInterval(259200)),
                date: DateFormatter.dateFormatter.string(from: Date().addingTimeInterval(259200)),
                condition: "Rain",
                iconName: "cloud.rain",
                highTemp: Int.random(in: 10...15),
                lowTemp: Int.random(in: 5...10),
                snowfall: 0,
                precipitationChance: 80
            ),
            DayForecast(
                dayOfWeek: DateFormatter.dayFormatter.string(from: Date().addingTimeInterval(345600)),
                date: DateFormatter.dateFormatter.string(from: Date().addingTimeInterval(345600)),
                condition: "Snow",
                iconName: "cloud.snow",
                highTemp: Int.random(in: 0...5),
                lowTemp: Int.random(in: -5...0),
                snowfall: Int.random(in: 5...15),
                precipitationChance: 90
            )
        ]
        return forecastDays
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Short day name (Mon, Tue, etc.)
        return formatter
    }()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // Jan 17
        return formatter
    }()
}

enum WeatherError: Error {
    case fetchFailed(String)
    case noDataAvailable
    
    var localizedDescription: String {
        switch self {
        case .fetchFailed(let reason):
            return "Failed to fetch weather: \(reason)"
        case .noDataAvailable:
            return "Weather data is currently unavailable"
        }
    }
} 