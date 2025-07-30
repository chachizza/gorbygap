//
//  WebcamViewModel.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import SwiftUI

@MainActor
class WebcamViewModel: ObservableObject {
    @Published var webcams: [WebcamData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: String = ""
    
    private let webcamService = WebcamService.shared
    
    init() {
        observeService()
        loadData()
    }
    
    private func observeService() {
        // Observe webcam service updates
        webcamService.$webcams
            .receive(on: DispatchQueue.main)
            .assign(to: &$webcams)
        
        webcamService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
        
        webcamService.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$errorMessage)
        
        webcamService.$lastUpdated
            .receive(on: DispatchQueue.main)
            .map { date in
                guard let date = date else { return "Never" }
                return DateFormatter.timeOnly.string(from: date)
            }
            .assign(to: &$lastUpdated)
    }
    
    func loadData() {
        // Data is already loaded by WebcamService
        print("✅ WebcamViewModel: Connected to WebcamService with \(webcamService.webcams.count) webcams")
    }
    
    func refreshData() async {
        await webcamService.refreshWebcams()
    }
} 