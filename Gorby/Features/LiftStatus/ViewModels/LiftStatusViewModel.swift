//
//  LiftStatusViewModel.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class LiftStatusViewModel: ObservableObject {
    @Published var lifts: [LiftData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: String = ""
    @Published var source: String = ""
    @Published var searchText: String = ""
    
    private let liftService = LiftStatusService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        observeService()
        Task {
            await loadData()
        }
    }
    
    private func observeService() {
        liftService.$lifts
            .receive(on: DispatchQueue.main)
            .assign(to: \.lifts, on: self)
            .store(in: &cancellables)
        
        liftService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        liftService.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
        
        liftService.$lastUpdated
            .receive(on: DispatchQueue.main)
            .assign(to: \.lastUpdated, on: self)
            .store(in: &cancellables)
        
        liftService.$source
            .receive(on: DispatchQueue.main)
            .assign(to: \.source, on: self)
            .store(in: &cancellables)
    }
    
    func loadData() async {
        await liftService.fetchLifts()
    }
    
    func refreshData() async {
        await liftService.refreshLifts()
    }
    
    func triggerManualRefresh() async {
        await liftService.manualRefresh()
    }
    
    // MARK: - Computed Properties
    
    var filteredLifts: [LiftData] {
        if searchText.isEmpty {
            return lifts
        }
        return lifts.filter { lift in
            lift.liftName.localizedCaseInsensitiveContains(searchText) ||
            lift.mountain.localizedCaseInsensitiveContains(searchText) ||
            lift.type.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var openLiftsCount: Int {
        lifts.filter { $0.isOpen }.count
    }
    
    var totalLiftsCount: Int {
        lifts.count
    }
    
    var liftsWithWaitTimes: Int {
        lifts.filter { $0.waitTime != nil && $0.isOpen }.count
    }
    
    var whistlerLifts: [LiftData] {
        lifts.filter { $0.mountain.lowercased() == "whistler" }
    }
    
    var blackcombLifts: [LiftData] {
        lifts.filter { $0.mountain.lowercased() == "blackcomb" }
    }
    
    var interconnectLifts: [LiftData] {
        lifts.filter { $0.mountain.lowercased() == "both" }
    }
    
    var dataSourceDescription: String {
        switch source {
        case "live-data":
            return "Live data"
        case "vail-maps-api-realtime":
            return "Live data"
        case "vail-resorts-api":
            return "Live data"
        case "fallback-data":
            return "Sample data"
        case "whistlerpeak.com":
            return "Live data"
        case "whistlerpeak.com-noai":
            return "Live data"
        case "fallback":
            return "Fallback data"
        case "no-data", "api-error":
            return "Data unavailable"
        default:
            return "Live data"
        }
    }
} 