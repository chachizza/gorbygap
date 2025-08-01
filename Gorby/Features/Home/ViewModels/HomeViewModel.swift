//
//  HomeViewModel.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import WeatherKit
import CoreLocation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var newSnowAmount: Int = 0
    @Published var snowLocation: String = "1850m"
    @Published var errorMessage: String?
    @Published var instagramPosts: [InstagramPost] = []
    @Published var instagramError: String?
    @Published var instagramTokenStatus: String = "Checking..."
    @Published var isLoadingInstagram = false
    
    private let instagramService = InstagramService()
    
    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
    
    init() {
        Task {
            await loadSnowData()
            await loadInstagramPosts()
        }
    }
    
    func loadSnowData() async {
        // TODO: Implement real snow data endpoint
        // WeatherKit doesn't provide snow depth data
        // Need to find alternative API for real snow measurements
        print("⚠️ Snow data not implemented - need real snow API endpoint")
        self.newSnowAmount = -1 // Use -1 to indicate N/A
        self.snowLocation = "1850m"
    }
    
    func loadInstagramPosts() async {
        isLoadingInstagram = true
        
        do {
            instagramPosts = try await instagramService.fetchInstagramPosts()
            let status = instagramService.getTokenStatus()
            instagramTokenStatus = ": \(status.isValid), Expires in: \(status.daysUntilExpiration) days"
        } catch {
            instagramError = error.localizedDescription
            instagramTokenStatus = "Token error: \(error.localizedDescription)"
        }
        
        isLoadingInstagram = false
    }
    
    func refreshData() async {
        await loadSnowData()
        await loadInstagramPosts()
    }
    
    func refreshInstagramToken() async {
        do {
            try await instagramService.manualRefreshToken()
            let status = instagramService.getTokenStatus()
            instagramTokenStatus = "Token refreshed! Valid for \(status.daysUntilExpiration) days"
        } catch {
            instagramTokenStatus = "Token refresh failed: \(error.localizedDescription)"
        }
    }
} 