//
//  SnowStakeView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import SwiftUI

struct SnowStakeView: View {
    @StateObject private var viewModel = SnowStakeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Snow Depth
                    CurrentSnowDepthCard(depth: viewModel.currentDepth, lastUpdated: viewModel.lastUpdated)
                    
                    // Live Camera Feed
                    SnowStakeCameraView(imageUrl: viewModel.currentImageUrl)
                    
                    // 12-Hour History
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Past 12 Hours")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.historicalImages) { image in
                                    HistoricalImageCard(image: image)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Snow Depth Chart
                    SnowDepthChart(dataPoints: viewModel.depthHistory)
                        .padding(.horizontal)
                }
                .padding(.top, 8)
                .padding(.bottom)
            }
            .navigationTitle("Snow Stake")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }
}

struct CurrentSnowDepthCard: View {
    let depth: Int
    let lastUpdated: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Current Snow Depth")
                    .font(.headline)
                
                Spacer()
                
                Text("Pig Alley")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                Text("\(depth)")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.blue)
                
                Text("centimeters")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("Last updated: \(lastUpdated)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct SnowStakeCameraView: View {
    let imageUrl: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Camera Feed")
                .font(.headline)
                .padding(.horizontal)
            
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(4/3, contentMode: .fit)
                
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("Snow Stake Camera")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(imageUrl)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

struct HistoricalImageCard: View {
    let image: HistoricalSnowImage
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 90)
                
                VStack {
                    Image(systemName: "camera")
                        .foregroundColor(.gray)
                    
                    Text("\(image.snowDepth) cm")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .cornerRadius(8)
            
            Text(image.timestamp)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct SnowDepthChart: View {
    let dataPoints: [SnowDepthDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("24-Hour Trend")
                .font(.title3)
                .fontWeight(.bold)
            
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                
                VStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    Text("Snow depth chart would display here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .cornerRadius(12)
        }
    }
}

#Preview {
    SnowStakeView()
} 