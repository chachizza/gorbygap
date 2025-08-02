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
    let message: String
    let timestamp: Date
    let threshold: Int
    let isRead: Bool
    
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(snowAmount, forKey: .snowAmount)
        try container.encode(message, forKey: .message)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(threshold, forKey: .threshold)
        try container.encode(isRead, forKey: .isRead)
    }
}
