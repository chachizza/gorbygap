//
//  WeatherData.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import SwiftUI

struct WeatherData: Identifiable, Codable {
    let id: UUID
    let temperature: Int
    
    init(temperature: Int, feelsLike: Int, condition: String, iconName: String, newSnow: Int, baseTemp: Int, windSpeed: Int, humidity: Int, visibility: String) {
        self.id = UUID()
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.condition = condition
        self.iconName = iconName
        self.newSnow = newSnow
        self.baseTemp = baseTemp
        self.windSpeed = windSpeed
        self.humidity = humidity
        self.visibility = visibility
    }
    
    private enum CodingKeys: String, CodingKey {
        case temperature, feelsLike, condition, iconName, newSnow, baseTemp, windSpeed, humidity, visibility
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.temperature = try container.decode(Int.self, forKey: .temperature)
        self.feelsLike = try container.decode(Int.self, forKey: .feelsLike)
        self.condition = try container.decode(String.self, forKey: .condition)
        self.iconName = try container.decode(String.self, forKey: .iconName)
        self.newSnow = try container.decode(Int.self, forKey: .newSnow)
        self.baseTemp = try container.decode(Int.self, forKey: .baseTemp)
        self.windSpeed = try container.decode(Int.self, forKey: .windSpeed)
        self.humidity = try container.decode(Int.self, forKey: .humidity)
        self.visibility = try container.decode(String.self, forKey: .visibility)
    }
    let feelsLike: Int
    let condition: String
    let iconName: String
    let newSnow: Int
    let baseTemp: Int
    let windSpeed: Int
    let humidity: Int
    let visibility: String
    
    static let mock = WeatherData(
        temperature: -8,
        feelsLike: -12,
        condition: "Light Snow",
        iconName: "snow",
        newSnow: 15,
        baseTemp: -5,
        windSpeed: 22,
        humidity: 78,
        visibility: "2 km"
    )
}

struct CurrentConditions: Identifiable, Codable {
    let id: UUID
    let baseDepth: Int
    
    init(baseDepth: Int, midDepth: Int, alpineDepth: Int, lastUpdated: String) {
        self.id = UUID()
        self.baseDepth = baseDepth
        self.midDepth = midDepth
        self.alpineDepth = alpineDepth
        self.lastUpdated = lastUpdated
    }
    
    private enum CodingKeys: String, CodingKey {
        case baseDepth, midDepth, alpineDepth, lastUpdated
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.baseDepth = try container.decode(Int.self, forKey: .baseDepth)
        self.midDepth = try container.decode(Int.self, forKey: .midDepth)
        self.alpineDepth = try container.decode(Int.self, forKey: .alpineDepth)
        self.lastUpdated = try container.decode(String.self, forKey: .lastUpdated)
    }
    let midDepth: Int
    let alpineDepth: Int
    let lastUpdated: String
    
    static let mock = CurrentConditions(
        baseDepth: 185,
        midDepth: 220,
        alpineDepth: 265,
        lastUpdated: "2 hours ago"
    )
}

struct DayForecast: Identifiable, Codable {
    let id: UUID
    let dayOfWeek: String
    let date: String
    let condition: String
    let iconName: String
    let highTemp: Int
    let lowTemp: Int
    let snowfall: Int
    let precipitationChance: Int
    
    init(dayOfWeek: String, date: String, condition: String, iconName: String, highTemp: Int, lowTemp: Int, snowfall: Int, precipitationChance: Int) {
        self.id = UUID()
        self.dayOfWeek = dayOfWeek
        self.date = date
        self.condition = condition
        self.iconName = iconName
        self.highTemp = highTemp
        self.lowTemp = lowTemp
        self.snowfall = snowfall
        self.precipitationChance = precipitationChance
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case dayOfWeek
        case date
        case condition
        case iconName
        case highTemp
        case lowTemp
        case snowfall
        case precipitationChance
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.dayOfWeek = try container.decode(String.self, forKey: .dayOfWeek)
        self.date = try container.decode(String.self, forKey: .date)
        self.condition = try container.decode(String.self, forKey: .condition)
        self.iconName = try container.decode(String.self, forKey: .iconName)
        self.highTemp = try container.decode(Int.self, forKey: .highTemp)
        self.lowTemp = try container.decode(Int.self, forKey: .lowTemp)
        self.snowfall = try container.decode(Int.self, forKey: .snowfall)
        self.precipitationChance = try container.decode(Int.self, forKey: .precipitationChance)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(dayOfWeek, forKey: .dayOfWeek)
        try container.encode(date, forKey: .date)
        try container.encode(condition, forKey: .condition)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(highTemp, forKey: .highTemp)
        try container.encode(lowTemp, forKey: .lowTemp)
        try container.encode(snowfall, forKey: .snowfall)
        try container.encode(precipitationChance, forKey: .precipitationChance)
    }
    
    static var mockForecast: [DayForecast] {
        let today = Date()
        let calendar = Calendar.current
        
        return [
            DayForecast(
                dayOfWeek: "Today",
                date: DateFormatter.dateFormatter.string(from: today),
                condition: "Sunny",
                iconName: "sun.max",
                highTemp: 25,
                lowTemp: 14,
                snowfall: 0,
                precipitationChance: 10
            ),
            DayForecast(
                dayOfWeek: "Tomorrow",
                date: DateFormatter.dateFormatter.string(from: calendar.date(byAdding: .day, value: 1, to: today) ?? today),
                condition: "Partly Cloudy",
                iconName: "cloud.sun",
                highTemp: 23,
                lowTemp: 13,
                snowfall: 0,
                precipitationChance: 20
            ),
            DayForecast(
                dayOfWeek: DateFormatter.dayFormatter.string(from: calendar.date(byAdding: .day, value: 2, to: today) ?? today),
                date: DateFormatter.dateFormatter.string(from: calendar.date(byAdding: .day, value: 2, to: today) ?? today),
                condition: "Cloudy",
                iconName: "cloud",
                highTemp: 21,
                lowTemp: 12,
                snowfall: 0,
                precipitationChance: 40
            ),
            DayForecast(
                dayOfWeek: DateFormatter.dayFormatter.string(from: calendar.date(byAdding: .day, value: 3, to: today) ?? today),
                date: DateFormatter.dateFormatter.string(from: calendar.date(byAdding: .day, value: 3, to: today) ?? today),
                condition: "Light Rain",
                iconName: "cloud.drizzle",
                highTemp: 19,
                lowTemp: 11,
                snowfall: 0,
                precipitationChance: 60
            ),
            DayForecast(
                dayOfWeek: DateFormatter.dayFormatter.string(from: calendar.date(byAdding: .day, value: 4, to: today) ?? today),
                date: DateFormatter.dateFormatter.string(from: calendar.date(byAdding: .day, value: 4, to: today) ?? today),
                condition: "Sunny",
                iconName: "sun.max",
                highTemp: 22,
                lowTemp: 13,
                snowfall: 0,
                precipitationChance: 0
            )
        ]
    }
} 