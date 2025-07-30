//
//  SnowStakeService.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import Combine

class SnowStakeService: ObservableObject {
    static let shared = SnowStakeService()
    
    @Published var snowStakeData: SnowStakeData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    @Published var currentImageUrl: String = ""
    @Published var fallbackUrls: [String] = []
    
    private var refreshTimer: Timer?
    private var currentUrlIndex = 0
    
    private init() {
        loadSnowStakeData()
        startAutoRefresh()
    }
    
    private func loadSnowStakeData() {
        snowStakeData = SnowStakeData()
        currentImageUrl = snowStakeData?.imageUrl ?? ""
        fallbackUrls = SnowStakeData.generateFallbackUrls()
        lastUpdated = Date()
    }
    
    func startAutoRefresh() {
        // Refresh every hour (3600 seconds)
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            self.refreshSnowStakeData()
        }
    }
    
    func refreshSnowStakeData() {
        isLoading = true
        errorMessage = nil
        
        // Try current URL first
        currentUrlIndex = 0
        tryNextUrl()
    }
    
    private func tryNextUrl() {
        let urls = [currentImageUrl] + fallbackUrls
        
        guard currentUrlIndex < urls.count else {
            // All URLs failed
            errorMessage = "Unable to load snow stake image"
            isLoading = false
            return
        }
        
        let urlToTry = urls[currentUrlIndex]
        
        // Test if URL is accessible
        guard let url = URL(string: urlToTry) else {
            currentUrlIndex += 1
            tryNextUrl()
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200,
                   data != nil {
                    // URL is accessible, update the data
                    self?.snowStakeData = SnowStakeData()
                    self?.currentImageUrl = urlToTry
                    self?.lastUpdated = Date()
                    self?.isLoading = false
                    self?.errorMessage = nil
                } else {
                    // Try next URL
                    self?.currentUrlIndex += 1
                    self?.tryNextUrl()
                }
            }
        }
        
        task.resume()
    }
    
    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    deinit {
        stopAutoRefresh()
    }
} 