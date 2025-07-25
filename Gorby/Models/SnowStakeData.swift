//
//  SnowStakeData.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation

struct HistoricalSnowImage: Identifiable, Codable {
    let id: UUID
    let timestamp: String
    
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
    let imageUrl: String
    let snowDepth: Int
    let captureTime: Date
    
    static let mockImages: [HistoricalSnowImage] = [
        HistoricalSnowImage(
            timestamp: "12:00 PM",
            imageUrl: "https://whistler.com/snow-stake/12pm.jpg",
            snowDepth: 245,
            captureTime: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
        ),
        HistoricalSnowImage(
            timestamp: "10:00 AM",
            imageUrl: "https://whistler.com/snow-stake/10am.jpg",
            snowDepth: 243,
            captureTime: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date()
        ),
        HistoricalSnowImage(
            timestamp: "8:00 AM",
            imageUrl: "https://whistler.com/snow-stake/8am.jpg",
            snowDepth: 241,
            captureTime: Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date()
        ),
        HistoricalSnowImage(
            timestamp: "6:00 AM",
            imageUrl: "https://whistler.com/snow-stake/6am.jpg",
            snowDepth: 238,
            captureTime: Calendar.current.date(byAdding: .hour, value: -7, to: Date()) ?? Date()
        ),
        HistoricalSnowImage(
            timestamp: "4:00 AM",
            imageUrl: "https://whistler.com/snow-stake/4am.jpg",
            snowDepth: 235,
            captureTime: Calendar.current.date(byAdding: .hour, value: -9, to: Date()) ?? Date()
        ),
        HistoricalSnowImage(
            timestamp: "2:00 AM",
            imageUrl: "https://whistler.com/snow-stake/2am.jpg",
            snowDepth: 232,
            captureTime: Calendar.current.date(byAdding: .hour, value: -11, to: Date()) ?? Date()
        )
    ]
}

struct SnowDepthDataPoint: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    
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
    let depth: Int
    let temperature: Int?
    let newSnow: Int?
    
    static let mockData: [SnowDepthDataPoint] = {
        var data: [SnowDepthDataPoint] = []
        let calendar = Calendar.current
        let now = Date()
        
        for i in 0..<24 {
            let time = calendar.date(byAdding: .hour, value: -i, to: now) ?? now
            let baseDepth = 245 - (i * 2) + Int.random(in: -3...3)
            let temp = -8 + Int.random(in: -4...4)
            let newSnow = i < 6 ? Int.random(in: 0...5) : 0
            
            data.append(SnowDepthDataPoint(
                timestamp: time,
                depth: baseDepth,
                temperature: temp,
                newSnow: newSnow
            ))
        }
        
        return data.reversed()
    }()
} 