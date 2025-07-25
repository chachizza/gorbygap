//
//  SnowStakeViewModel.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation

@MainActor
class SnowStakeViewModel: ObservableObject {
    @Published var currentDepth: Int = 0
    @Published var lastUpdated: String = ""
    @Published var currentImageUrl: String = ""
    @Published var historicalImages: [HistoricalSnowImage] = []
    @Published var depthHistory: [SnowDepthDataPoint] = []
    @Published var isLoading = false
    
    init() {
        loadMockData()
    }
    
    func loadMockData() {
        currentDepth = 245
        lastUpdated = DateFormatter.timeOnly.string(from: Date())
        currentImageUrl = "https://whistler.com/snow-stake/current.jpg"
        historicalImages = HistoricalSnowImage.mockImages
        depthHistory = SnowDepthDataPoint.mockData
    }
    
    func refreshData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // In a real app, this would call the snow stake service
        loadMockData()
    }
}

extension DateFormatter {
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
} 