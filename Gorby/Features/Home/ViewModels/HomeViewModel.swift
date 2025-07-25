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
        // Set summer conditions (no snow)
        newSnowAmount = 0
        
        Task {
            await loadInstagramPosts()
        }
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