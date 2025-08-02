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
    let waitTime: Int?
    let capacity: Int
    let lastUpdated: String
    
    private enum CodingKeys: String, CodingKey {
        case liftName, status, mountain, type, waitTime, capacity, lastUpdated
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
        case "maintenance":
            return "purple"
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
    
    var waitTimeText: String {
        // Only show wait times for open lifts
        guard isOpen else { return "N/A" }
        
        guard let waitTime = waitTime else { return "N/A" }
        if waitTime == 0 {
            return "No wait"
        } else if waitTime < 5 {
            return "< 5 min"
        } else if waitTime < 10 {
            return "5-10 min"
        } else if waitTime < 15 {
            return "10-15 min"
        } else if waitTime < 30 {
            return "15-30 min"
        } else {
            return "30+ min"
        }
    }
    
    var waitTimeColor: String {
        // Only show wait time colors for open lifts
        guard isOpen else { return "gray" }
        
        guard let waitTime = waitTime else { return "gray" }
        if waitTime == 0 {
            return "green"
        } else if waitTime < 5 {
            return "yellow"
        } else if waitTime < 15 {
            return "orange"
        } else {
            return "red"
        }
    }
    
    var capacityText: String {
        if capacity == 0 {
            return "N/A"
        } else if capacity == 1 {
            return "1 person"
        } else {
            return "\(capacity) people"
        }
    }
}

// MARK: - Mock Data (REMOVED - No mock data allowed)
// static let mockLifts: [LiftData] = [] 