//
//  SnowStakeData.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation

struct SnowStakeData: Identifiable, Codable {
    let id: UUID
    let currentDepth: Int
    let newSnow: Int
    let baseDepth: Int
    let midDepth: Int
    let alpineDepth: Int
    let lastUpdated: String
    let temperature: Int
    let condition: String
    
    // Default initializer for placeholder data
    init() {
        self.id = UUID()
        self.currentDepth = 0
        self.newSnow = 0
        self.baseDepth = 0
        self.midDepth = 0
        self.alpineDepth = 0
        self.lastUpdated = "N/A"
        self.temperature = 0
        self.condition = "Unknown"
    }
    
    init(currentDepth: Int, newSnow: Int, baseDepth: Int, midDepth: Int, alpineDepth: Int, lastUpdated: String, temperature: Int, condition: String) {
        self.id = UUID()
        self.currentDepth = currentDepth
        self.newSnow = newSnow
        self.baseDepth = baseDepth
        self.midDepth = midDepth
        self.alpineDepth = alpineDepth
        self.lastUpdated = lastUpdated
        self.temperature = temperature
        self.condition = condition
    }
    
    // Generate image URL based on current time
    var imageUrl: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH"
        let currentTime = formatter.string(from: Date())
        return "https://whistlerpeak.com/snow/stake_img/\(currentTime).jpg"
    }
    
    // Static method to generate fallback URLs
    static func generateFallbackUrls() -> [String] {
        let calendar = Calendar.current
        var urls: [String] = []
        
        // Try previous 3 hours as fallback
        for i in 1...3 {
            if let previousHour = calendar.date(byAdding: .hour, value: -i, to: Date()) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd-HH"
                let timeString = formatter.string(from: previousHour)
                urls.append("https://whistlerpeak.com/snow/stake_img/\(timeString).jpg")
            }
        }
        
        return urls
    }
    
    private enum CodingKeys: String, CodingKey {
        case currentDepth, newSnow, baseDepth, midDepth, alpineDepth, lastUpdated, temperature, condition
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.currentDepth = try container.decode(Int.self, forKey: .currentDepth)
        self.newSnow = try container.decode(Int.self, forKey: .newSnow)
        self.baseDepth = try container.decode(Int.self, forKey: .baseDepth)
        self.midDepth = try container.decode(Int.self, forKey: .midDepth)
        self.alpineDepth = try container.decode(Int.self, forKey: .alpineDepth)
        self.lastUpdated = try container.decode(String.self, forKey: .lastUpdated)
        self.temperature = try container.decode(Int.self, forKey: .temperature)
        self.condition = try container.decode(String.self, forKey: .condition)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentDepth, forKey: .currentDepth)
        try container.encode(newSnow, forKey: .newSnow)
        try container.encode(baseDepth, forKey: .baseDepth)
        try container.encode(midDepth, forKey: .midDepth)
        try container.encode(alpineDepth, forKey: .alpineDepth)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encode(temperature, forKey: .temperature)
        try container.encode(condition, forKey: .condition)
    }
}

struct HistoricalSnowImage: Identifiable, Codable {
    let id: UUID
    let timestamp: String
    let imageUrl: String
    let snowDepth: Int
    let captureTime: Date
    
    init(timestamp: String, imageUrl: String, snowDepth: Int, captureTime: Date) {
        self.id = UUID()
        self.timestamp = timestamp
        self.imageUrl = imageUrl
        self.snowDepth = snowDepth
        self.captureTime = captureTime
    }
    
    private enum CodingKeys: String, CodingKey {
        case timestamp, imageUrl, snowDepth, captureTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.timestamp = try container.decode(String.self, forKey: .timestamp)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
        self.snowDepth = try container.decode(Int.self, forKey: .snowDepth)
        self.captureTime = try container.decode(Date.self, forKey: .captureTime)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(snowDepth, forKey: .snowDepth)
        try container.encode(captureTime, forKey: .captureTime)
    }
}

struct SnowDepthDataPoint: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let depth: Int
    let temperature: Int?
    let newSnow: Int?
    
    init(timestamp: Date, depth: Int, temperature: Int?, newSnow: Int?) {
        self.id = UUID()
        self.timestamp = timestamp
        self.depth = depth
        self.temperature = temperature
        self.newSnow = newSnow
    }
    
    private enum CodingKeys: String, CodingKey {
        case timestamp, depth, temperature, newSnow
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.depth = try container.decode(Int.self, forKey: .depth)
        self.temperature = try container.decodeIfPresent(Int.self, forKey: .temperature)
        self.newSnow = try container.decodeIfPresent(Int.self, forKey: .newSnow)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(depth, forKey: .depth)
        try container.encodeIfPresent(temperature, forKey: .temperature)
        try container.encodeIfPresent(newSnow, forKey: .newSnow)
    }
}
