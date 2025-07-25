//
//  SnowAlert.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation

struct SnowAlert: Identifiable, Codable {
    let id: UUID
    let snowAmount: Int
    
    init(snowAmount: Int, message: String, timestamp: Date, threshold: Int, isRead: Bool) {
        self.id = UUID()
        self.snowAmount = snowAmount
        self.message = message
        self.timestamp = timestamp
        self.threshold = threshold
        self.isRead = isRead
    }
    
    private enum CodingKeys: String, CodingKey {
        case snowAmount, message, timestamp, threshold, isRead
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.snowAmount = try container.decode(Int.self, forKey: .snowAmount)
        self.message = try container.decode(String.self, forKey: .message)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.threshold = try container.decode(Int.self, forKey: .threshold)
        self.isRead = try container.decode(Bool.self, forKey: .isRead)
    }
    let message: String
    let timestamp: Date
    let threshold: Int
    let isRead: Bool
    
    static let mockAlerts: [SnowAlert] = [
        SnowAlert(
            snowAmount: 25,
            message: "Heavy snowfall overnight! 25cm of fresh powder awaits.",
            timestamp: Calendar.current.date(byAdding: .hour, value: -8, to: Date()) ?? Date(),
            threshold: 20,
            isRead: true
        ),
        SnowAlert(
            snowAmount: 15,
            message: "Fresh snow alert! 15cm of new snow since yesterday.",
            timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            threshold: 10,
            isRead: true
        ),
        SnowAlert(
            snowAmount: 32,
            message: "Epic powder day! 32cm of fresh snow reported.",
            timestamp: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            threshold: 30,
            isRead: true
        ),
        SnowAlert(
            snowAmount: 18,
            message: "Good news! 18cm of new snow since this morning.",
            timestamp: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            threshold: 15,
            isRead: false
        )
    ]
} 