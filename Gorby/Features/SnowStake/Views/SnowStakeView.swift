//
//  SnowStakeView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import SwiftUI

struct SnowStakeView: View {
    @StateObject private var viewModel = SnowStakeViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Main snow stake image
                    SnowStakeImageCard(viewModel: viewModel)
                        .padding(.horizontal, 20)
                    
                    // Grid of recent images
                    SnowStakeGrid(viewModel: viewModel)
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Snow Stake")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                viewModel.refreshData()
            }
        }
    }
}

struct SnowStakeImageCard: View {
    @ObservedObject var viewModel: SnowStakeViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var hasError = false
    @State private var retryCount = 0
    @State private var hasLoadedOnce = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Image container with full size
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(maxWidth: .infinity, maxHeight: 400)
                
                if isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        Text("Loading snow stake...")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                } else if hasError {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        Text("Failed to load image")
                            .font(.headline)
                            .foregroundColor(.white)
                        if retryCount < 3 {
                            Button("Retry") {
                                loadImage()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.top, 8)
                        }
                    }
                } else if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 400)
                        .clipped()
                }
                
                // Time badge overlay
                VStack {
                    HStack {
                        Spacer()
                        Text(formatCurrentTime())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(mainImageBadgeColor)
                            .cornerRadius(12)
                            .padding(.top, 12)
                            .padding(.trailing, 12)
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 400)
            .clipped()
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            if !hasLoadedOnce {
                loadImage()
            }
        }
        .onChange(of: viewModel.currentImageUrl) { oldValue, newValue in
            if hasLoadedOnce {
                loadImage()
            }
        }
    }
    
    private var mainImageBadgeColor: Color {
        // Bright pink/magenta for main image (same as PEAK in Temps)
        return Color(red: 1.0, green: 0.2, blue: 0.8)
    }
    
    private func formatCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
    
    private func loadImage() {
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(for: viewModel.currentImageUrl) {
            self.image = cachedImage
            self.isLoading = false
            self.hasError = false
            self.hasLoadedOnce = true
            return
        }
        
        isLoading = true
        hasError = false
        
        guard let url = URL(string: viewModel.currentImageUrl) else {
            hasError = true
            isLoading = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("Error loading snow stake image: \(error.localizedDescription)")
                    hasError = true
                    retryCount += 1
                    return
                }
                
                guard let data = data, let loadedImage = UIImage(data: data) else {
                    print("Invalid snow stake image data")
                    hasError = true
                    retryCount += 1
                    return
                }
                
                // Cache the image
                ImageCache.shared.setImage(loadedImage, for: viewModel.currentImageUrl)
                
                self.image = loadedImage
                self.hasError = false
                self.retryCount = 0
                self.hasLoadedOnce = true
            }
        }
        
        task.resume()
    }
}

struct SnowStakeGrid: View {
    @ObservedObject var viewModel: SnowStakeViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ], spacing: 8) {
            ForEach(generateTimelineUrls()) { urlData in
                GridImageCard(
                    imageUrl: urlData.url,
                    timestamp: urlData.timestamp,
                    isCurrent: urlData.isCurrent,
                    index: urlData.index
                )
            }
        }
    }
    
    private func generateTimelineUrls() -> [TimelineUrlData] {
        let calendar = Calendar.current
        let now = Date()
        var urls: [TimelineUrlData] = []
        
        // Generate URLs for the last 4 hours (2 rows of 2)
        for i in 1...4 {
            if let hour = calendar.date(byAdding: .hour, value: -i, to: now) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd-HH"
                let timeString = formatter.string(from: hour)
                let url = "https://whistlerpeak.com/snow/stake_img/\(timeString).jpg"
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm a"
                let timestamp = timeFormatter.string(from: hour)
                
                urls.append(TimelineUrlData(
                    url: url,
                    timestamp: timestamp,
                    isCurrent: false,
                    index: i - 1
                ))
            }
        }
        
        return urls
    }
}

struct GridImageCard: View {
    let imageUrl: String
    let timestamp: String
    let isCurrent: Bool
    let index: Int
    @State private var image: UIImage?
    @State private var isLoading = true
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 100)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.6)
                } else if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .clipped()
                } else {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // Time badge overlay
                VStack {
                    HStack {
                        Spacer()
                        Text(timestamp)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(gridBadgeColor)
                            .cornerRadius(6)
                            .padding(.top, 2)
                            .padding(.trailing, 2)
                    }
                    Spacer()
                }
            }
            .frame(height: 100)
            .clipped()
            .cornerRadius(8)
        }
        .onAppear {
            loadImage()
        }
    }
    
    private var gridBadgeColor: Color {
        // Use different colors for each grid image, inspired by Temps page
        switch index {
        case 0:
            return Color(red: 0.6, green: 0.2, blue: 1.0) // Purple (7TH HEAVEN)
        case 1:
            return Color(red: 1.0, green: 0.5, blue: 0.0) // Orange (ROUNDHOUSE)
        case 2:
            return Color(red: 0.0, green: 0.7, blue: 0.8) // Turquoise (RENDEZVOUS)
        case 3:
            return Color(red: 0.2, green: 0.8, blue: 0.4) // Green (MIDSTATION)
        default:
            return Color(red: 1.0, green: 0.4, blue: 0.8) // Lighter pink (VILLAGE)
        }
    }
    
    private func loadImage() {
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(for: imageUrl) {
            self.image = cachedImage
            self.isLoading = false
            return
        }
        
        guard let url = URL(string: imageUrl) else {
            isLoading = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let data = data, let loadedImage = UIImage(data: data) {
                    ImageCache.shared.setImage(loadedImage, for: imageUrl)
                    self.image = loadedImage
                }
            }
        }
        
        task.resume()
    }
}

struct TimelineUrlData: Identifiable, Hashable {
    let id = UUID()
    let url: String
    let timestamp: String
    let isCurrent: Bool
    let index: Int
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(timestamp)
        hasher.combine(isCurrent)
        hasher.combine(index)
    }
    
    static func == (lhs: TimelineUrlData, rhs: TimelineUrlData) -> Bool {
        return lhs.url == rhs.url && lhs.timestamp == rhs.timestamp && lhs.isCurrent == rhs.isCurrent && lhs.index == rhs.index
    }
}

#Preview {
    SnowStakeView()
        .environmentObject(ThemeManager())
} 