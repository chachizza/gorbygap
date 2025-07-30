//
//  LiftData.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation

// MARK: - API Response Structure
struct LiftDataResponse: Codable {
    let lastUpdated: String
    let source: String
    let liftCount: Int
    let lifts: [LiftData]
}

// MARK: - Individual Lift Data
struct LiftData: Codable, Identifiable {
    let id = UUID()
    let liftName: String
    let status: String
    let mountain: String
    let type: String
    let lastUpdated: String
    
    private enum CodingKeys: String, CodingKey {
        case liftName, status, mountain, type, lastUpdated
    }
    
    // Computed properties for UI
    var isOpen: Bool {
        return status.lowercased() == "open"
    }
    
    var statusColor: String {
        switch status.lowercased() {
        case "open":
            return "green"
        case "closed":
            return "red"
        case "scheduled":
            return "orange"
        case "on hold":
            return "yellow"
        default:
            return "gray"
        }
    }
    
    var mountainEmoji: String {
        switch mountain.lowercased() {
        case "whistler":
            return "W"
        case "blackcomb":
            return "B"
        case "both":
            return "P2P"
        default:
            return "L"
        }
    }
}

// MARK: - Mock Data for Previews
extension LiftData {
    static let mockLifts: [LiftData] = [
        LiftData(liftName: "Peak Express", status: "Open", mountain: "Whistler", type: "Express Chair", lastUpdated: "2025-01-24T15:30:00Z"),
        LiftData(liftName: "Blackcomb Gondola", status: "Open", mountain: "Blackcomb", type: "Gondola", lastUpdated: "2025-01-24T15:30:00Z")
    ]
} 