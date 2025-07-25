//
//  LiftStatusService.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import Combine

@MainActor
class LiftStatusService: ObservableObject {
    static let shared = LiftStatusService()
    
    @Published var lifts: [LiftData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: String = ""
    @Published var source: String = ""
    
    // MARK: - Configuration
    private var baseURL: String {
        #if DEBUG
        // Development: Use localhost for simulator, Mac IP for device testing
        #if targetEnvironment(simulator)
        return "http://localhost:3001/api"
        #else
        // For testing on real device with local server
        // Update this IP with your Mac's IP if testing locally: ifconfig | grep "inet " | grep -v 127.0.0.1
        return "http://192.168.1.100:3001/api" // 👈 UPDATE THIS WITH YOUR MAC'S IP IF TESTING LOCALLY
        #endif
        #else
        // Production: Use your deployed Render server URL
        // 🚀 UPDATE THIS AFTER RENDER DEPLOYMENT
        return "https://gorby-backend.onrender.com/api" // 👈 WILL UPDATE WITH YOUR ACTUAL RENDER URL
        #endif
    }
    
    private init() {}
    
    func fetchLifts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let url = URL(string: "\(baseURL)/lifts") else {
                throw LiftServiceError.invalidURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw LiftServiceError.badResponse
            }
            
            let liftResponse = try JSONDecoder().decode(LiftDataResponse.self, from: data)
            
            lifts = liftResponse.lifts
            lastUpdated = formatLastUpdated(liftResponse.lastUpdated)
            source = liftResponse.source
            
            print("✅ Loaded \(lifts.count) lifts from ChatGPT-powered backend")
            
        } catch {
            errorMessage = "Failed to load lift status: \(error.localizedDescription)"
            print("❌ Lift fetch error: \(error)")
            
            // Use fallback data if available
            if lifts.isEmpty {
                lifts = LiftData.mockLifts
                source = "fallback"
                lastUpdated = "Just now"
            }
        }
        
        isLoading = false
    }
    
    func refreshLifts() async {
        await fetchLifts()
    }
    
    func manualRefresh() async {
        do {
            guard let url = URL(string: "\(baseURL)/lifts/refresh") else {
                throw LiftServiceError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw LiftServiceError.badResponse
            }
            
            print("✅ Manual refresh triggered successfully")
            
            // Wait a moment for the data to be processed
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // Fetch the updated data
            await fetchLifts()
            
        } catch {
            errorMessage = "Manual refresh failed: \(error.localizedDescription)"
            print("❌ Manual refresh error: \(error)")
        }
    }
    
    private func formatLastUpdated(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            return timeFormatter.string(from: date)
        }
        return "Recently"
    }
}

enum LiftServiceError: Error, LocalizedError {
    case invalidURL
    case badResponse
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .badResponse:
            return "Bad server response"
        case .decodingError:
            return "Failed to decode data"
        }
    }
} 