//
//  SnowStakeViewModel.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import Combine

class SnowStakeViewModel: ObservableObject {
    @Published var snowStakeData: SnowStakeData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    @Published var currentImageUrl: String = ""
    
    private let snowStakeService = SnowStakeService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        snowStakeService.$snowStakeData
            .assign(to: \.snowStakeData, on: self)
            .store(in: &cancellables)
        
        snowStakeService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        snowStakeService.$errorMessage
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
        
        snowStakeService.$lastUpdated
            .assign(to: \.lastUpdated, on: self)
            .store(in: &cancellables)
        
        snowStakeService.$currentImageUrl
            .assign(to: \.currentImageUrl, on: self)
            .store(in: &cancellables)
    }
    
    func refreshData() {
        snowStakeService.refreshSnowStakeData()
    }
} 