//
//  TemperatureData.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import SwiftUI

struct TemperatureStation: Identifiable, Codable {
    let id: UUID
    let name: String
    let temperature: Double
    let windSpeed: Int
    let color: Color
    let lastUpdated: String
    
    init(name: String, temperature: Double, windSpeed: Int, color: Color, lastUpdated: String) {
        self.id = UUID()
        self.name = name
        self.temperature = temperature
        self.windSpeed = windSpeed
        self.color = color
        self.lastUpdated = lastUpdated
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, temperature, windSpeed, lastUpdated
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.temperature = try container.decode(Double.self, forKey: .temperature)
        self.windSpeed = try container.decode(Int.self, forKey: .windSpeed)
        self.color = .blue // Default color for decoded stations
        self.lastUpdated = try container.decode(String.self, forKey: .lastUpdated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(temperature, forKey: .temperature)
        try container.encode(windSpeed, forKey: .windSpeed)
        try container.encode(lastUpdated, forKey: .lastUpdated)
    }
}

struct QuickLink: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let destination: String
}

struct LatestUpdate: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let timeAgo: String
    let icon: String
    let iconColor: Color
    
    init(title: String, description: String, timeAgo: String, icon: String, iconColor: Color) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.timeAgo = timeAgo
        self.icon = icon
        self.iconColor = iconColor
    }
    
    private enum CodingKeys: String, CodingKey {
        case title, description, timeAgo, icon
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.timeAgo = try container.decode(String.self, forKey: .timeAgo)
        self.icon = try container.decode(String.self, forKey: .icon)
        self.iconColor = .blue // Default color for decoded updates
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(timeAgo, forKey: .timeAgo)
        try container.encode(icon, forKey: .icon)
    }
} 