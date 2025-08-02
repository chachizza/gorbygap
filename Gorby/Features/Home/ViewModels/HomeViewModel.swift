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
    private let errorHandler = ErrorHandlingService.shared
    
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
        instagramError = nil
        
        do {
            instagramPosts = try await instagramService.fetchInstagramPosts()
            let status = instagramService.getTokenStatus()
            instagramTokenStatus = "Valid - Expires in \(status.daysUntilExpiration) days"
            
        } catch {
            let appError = AppError.fromError(error, context: "Loading Instagram posts")
            instagramError = appError.message
            instagramTokenStatus = "Error: \(appError.message)"
            
            // Log error but don't show alert for Instagram failures (non-critical)
            errorHandler.handleError(error, context: "Instagram posts", showToUser: false)
        }
        
        isLoadingInstagram = false
    }
    
    func refreshData() async {
        isLoading = true
        await loadSnowData()
        await loadInstagramPosts()
        isLoading = false
    }
    
    func refreshInstagramToken() async {
        do {
            try await instagramService.manualRefreshToken()
            let status = instagramService.getTokenStatus()
            instagramTokenStatus = "Refreshed! Valid for \(status.daysUntilExpiration) days"
            instagramError = nil
            
        } catch {
            let appError = AppError.fromError(error, context: "Refreshing Instagram token")
            instagramTokenStatus = "Refresh failed: \(appError.message)"
            instagramError = appError.message
            
            // Show error for token refresh since user explicitly requested it
            errorHandler.handleError(error, context: "Instagram token refresh", showToUser: true)
        }
    }
    
    /// Retry Instagram loading with user feedback
    func retryInstagram() async {
        await loadInstagramPosts()
    }
}
