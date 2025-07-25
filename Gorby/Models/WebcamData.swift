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
    
    init(name: String, location: String, url: String, isLive: Bool, lastUpdated: String, elevation: Int?) {
        self.id = UUID()
        self.name = name
        self.location = location
        self.url = url
        self.isLive = isLive
        self.lastUpdated = lastUpdated
        self.elevation = elevation
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, location, url, isLive, lastUpdated, elevation
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.location = try container.decode(String.self, forKey: .location)
        self.url = try container.decode(String.self, forKey: .url)
        self.isLive = try container.decode(Bool.self, forKey: .isLive)
        self.lastUpdated = try container.decode(String.self, forKey: .lastUpdated)
        self.elevation = try container.decodeIfPresent(Int.self, forKey: .elevation)
    }
    let location: String
    let url: String
    let isLive: Bool
    let lastUpdated: String
    let elevation: Int?
    
    // Mock data removed - using live data only per .cursorrules
    // All webcam data now comes from WebcamService via live backend API
} 