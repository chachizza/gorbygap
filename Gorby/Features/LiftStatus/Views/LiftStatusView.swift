//
//  LiftStatusView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import SwiftUI

struct LiftStatusView: View {
    @StateObject private var viewModel = LiftStatusViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingManualRefresh = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Status Header
                StatusHeaderView(viewModel: viewModel, themeManager: themeManager)
                
                if viewModel.isLoading && viewModel.lifts.isEmpty {
                    // Loading State
                    LoadingView()
                } else if let error = viewModel.errorMessage, viewModel.lifts.isEmpty {
                    // Error State
                    ErrorView(error: error, onRetry: {
                        Task { await viewModel.refreshData() }
                    })
                } else {
                    // Main Content
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Search Bar
                            SearchBar(searchText: $viewModel.searchText, themeManager: themeManager)
                            
                            // Lifts by Mountain
                            if !viewModel.whistlerLifts.isEmpty {
                                MountainSection(
                                    title: "Whistler Mountain",
                                    lifts: viewModel.filteredLifts.filter { $0.mountain.lowercased() == "whistler" },
                                    themeManager: themeManager
                                )
                            }
                            
                            if !viewModel.blackcombLifts.isEmpty {
                                MountainSection(
                                    title: "Blackcomb Mountain", 
                                    lifts: viewModel.filteredLifts.filter { $0.mountain.lowercased() == "blackcomb" },
                                    themeManager: themeManager
                                )
                            }
                            
                            if !viewModel.interconnectLifts.isEmpty {
                                MountainSection(
                                    title: "Interconnect",
                                    lifts: viewModel.filteredLifts.filter { $0.mountain.lowercased() == "both" },
                                    themeManager: themeManager
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Lift Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingManualRefresh = true
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                    }
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .alert("Manual Refresh", isPresented: $showingManualRefresh) {
                Button("Cancel", role: .cancel) { }
                Button("Refresh with ChatGPT") {
                    Task {
                        await viewModel.triggerManualRefresh()
                    }
                }
            } message: {
                Text("This will trigger a fresh scrape using ChatGPT to parse the latest data from Whistler's website.")
            }
        }
        .background(themeManager.currentTheme.backgroundColor)
    }
}

struct StatusHeaderView: View {
    @ObservedObject var viewModel: LiftStatusViewModel
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(viewModel.openLiftsCount)/\(viewModel.totalLiftsCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.currentTheme.textColor)
                        
                        Text("Open")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Lifts Operating")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.dataSourceDescription)
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                        .fontWeight(.medium)
                    
                    if !viewModel.lastUpdated.isEmpty {
                        Text("Updated: \(viewModel.lastUpdated)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Status indicators
            HStack(spacing: 12) {
                StatusIndicator(color: .green, label: "Open", count: viewModel.openLiftsCount)
                StatusIndicator(color: .red, label: "Closed", count: viewModel.totalLiftsCount - viewModel.openLiftsCount)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardBackgroundColor)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3)),
            alignment: .bottom
        )
    }
}

struct StatusIndicator: View {
    let color: Color
    let label: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search lifts...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(themeManager.currentTheme.cardBackgroundColor)
        .cornerRadius(10)
    }
}

struct MountainSection: View {
    let title: String
    let lifts: [LiftData]
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.textColor)
                .padding(.horizontal, 4)
            
            ForEach(lifts) { lift in
                LiftCard(lift: lift, themeManager: themeManager)
            }
        }
    }
}

struct LiftCard: View {
    let lift: LiftData
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(lift.liftName)
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                Text(lift.type)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                    
                    Text(lift.status)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(statusColor)
                }
                
                Text(lift.mountainEmoji)
                    .font(.caption)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var statusColor: Color {
        switch lift.status.lowercased() {
        case "open":
            return .green
        case "closed":
            return .red
        case "scheduled":
            return .orange
        case "on hold":
            return .yellow
        default:
            return .gray
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading lift status...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("🤖 ChatGPT is parsing live data")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let error: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Unable to load lift status")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                onRetry()
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LiftStatusView()
        .environmentObject(ThemeManager())
} 