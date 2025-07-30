//
//  WebcamData.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation

struct WebcamData: Identifiable, Codable {
    let id: UUID
    let name: String
    let cameraId: String
    let location: String
    let snapshotUrl: String
    let liveUrl: String
    let isLive: Bool
    let lastUpdated: String
    let elevation: Int?
    
    init(name: String, cameraId: String, location: String, elevation: Int?) {
        self.id = UUID()
        self.name = name
        self.cameraId = cameraId
        self.location = location
        self.snapshotUrl = "https://player.brownrice.com/snapshot/\(cameraId)"
        self.liveUrl = "https://player.brownrice.com/embed/\(cameraId)"
        self.isLive = true
        self.lastUpdated = DateFormatter.timeOnly.string(from: Date())
        self.elevation = elevation
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, cameraId, location, snapshotUrl, liveUrl, isLive, lastUpdated, elevation
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.cameraId = try container.decode(String.self, forKey: .cameraId)
        self.location = try container.decode(String.self, forKey: .location)
        self.snapshotUrl = try container.decode(String.self, forKey: .snapshotUrl)
        self.liveUrl = try container.decode(String.self, forKey: .liveUrl)
        self.isLive = try container.decode(Bool.self, forKey: .isLive)
        self.lastUpdated = try container.decode(String.self, forKey: .lastUpdated)
        self.elevation = try container.decodeIfPresent(Int.self, forKey: .elevation)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(cameraId, forKey: .cameraId)
        try container.encode(location, forKey: .location)
        try container.encode(snapshotUrl, forKey: .snapshotUrl)
        try container.encode(liveUrl, forKey: .liveUrl)
        try container.encode(isLive, forKey: .isLive)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encode(elevation, forKey: .elevation)
    }
}

extension DateFormatter {
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
} 