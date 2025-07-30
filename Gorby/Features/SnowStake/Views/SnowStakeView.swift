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
                    
                    // Horizontal timeline of recent images
                    SnowStakeTimeline(viewModel: viewModel)
                        .padding(.horizontal, 20)
                    
                    // Info section
                    SnowStakeInfoCard()
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
            // Image container with proper aspect ratio
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: themeManager.currentTheme == .greyscale ? 
                                [Color.gray.opacity(0.3), Color.gray.opacity(0.5)] : 
                                [Color(red: 1.0, green: 0.2, blue: 0.8), Color(red: 0.9, green: 0.1, blue: 0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(maxWidth: .infinity, minHeight: 250)
                
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
                        .frame(maxWidth: .infinity, minHeight: 250)
                        .clipped()
                        .cornerRadius(20)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 250)
            
            // Timestamp below image
            if let snowStakeData = viewModel.snowStakeData {
                HStack {
                    Spacer()
                    Text("Image from \(DateFormatter.dateTime.string(from: snowStakeData.timestamp))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 8)
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: themeManager.currentTheme == .greyscale ? 
                            [Color.gray.opacity(0.3), Color.gray.opacity(0.5)] : 
                            [Color(red: 1.0, green: 0.2, blue: 0.8), Color(red: 0.9, green: 0.1, blue: 0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: themeManager.currentTheme == .greyscale ? 
                        Color.gray.opacity(0.3) : Color(red: 1.0, green: 0.2, blue: 0.8).opacity(0.4), 
                        radius: 8, x: 0, y: 4)
        )
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

struct SnowStakeTimeline: View {
    @ObservedObject var viewModel: SnowStakeViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.white)
                Text("Recent Images")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(generateTimelineUrls()) { urlData in
                        TimelineImageCard(
                            imageUrl: urlData.url,
                            timestamp: urlData.timestamp,
                            isCurrent: urlData.isCurrent
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: themeManager.currentTheme == .greyscale ? 
                            [Color.gray.opacity(0.3), Color.gray.opacity(0.5)] : 
                            [Color(red: 0.0, green: 0.7, blue: 0.8), Color(red: 0.1, green: 0.9, blue: 1.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: themeManager.currentTheme == .greyscale ? 
                        Color.gray.opacity(0.3) : Color(red: 0.0, green: 0.7, blue: 0.8).opacity(0.4), 
                        radius: 8, x: 0, y: 4)
        )
    }
    
    private func generateTimelineUrls() -> [TimelineUrlData] {
        let calendar = Calendar.current
        let now = Date()
        var urls: [TimelineUrlData] = []
        
        // Generate URLs for the last 5 hours
        for i in 0..<5 {
            if let hour = calendar.date(byAdding: .hour, value: -i, to: now) {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd-HH"
                let timeString = formatter.string(from: hour)
                let url = "https://whistlerpeak.com/snow/stake_img/\(timeString).jpg"
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                let timestamp = timeFormatter.string(from: hour)
                
                urls.append(TimelineUrlData(
                    url: url,
                    timestamp: timestamp,
                    isCurrent: i == 0
                ))
            }
        }
        
        return urls
    }
}

struct TimelineImageCard: View {
    let imageUrl: String
    let timestamp: String
    let isCurrent: Bool
    @State private var image: UIImage?
    @State private var isLoading = true
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 80, height: 60)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 60)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                if isCurrent {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 80, height: 60)
                }
            }
            
            Text(timestamp)
                .font(.caption)
                .fontWeight(isCurrent ? .bold : .medium)
                .foregroundColor(.white)
        }
        .onAppear {
            loadImage()
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

struct SnowStakeInfoCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "ruler")
                    .foregroundColor(.white)
                Text("Snow Ruler")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            Text("Live snow stake image from Whistler Peak")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.white)
                Text("Updates hourly")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: themeManager.currentTheme == .greyscale ? 
                            [Color.gray.opacity(0.3), Color.gray.opacity(0.5)] : 
                            [Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 1.0, green: 0.7, blue: 0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: themeManager.currentTheme == .greyscale ? 
                        Color.gray.opacity(0.3) : Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.4), 
                        radius: 8, x: 0, y: 4)
        )
    }
}

struct TimelineUrlData: Identifiable, Hashable {
    let id = UUID()
    let url: String
    let timestamp: String
    let isCurrent: Bool
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(timestamp)
        hasher.combine(isCurrent)
    }
    
    static func == (lhs: TimelineUrlData, rhs: TimelineUrlData) -> Bool {
        return lhs.url == rhs.url && lhs.timestamp == rhs.timestamp && lhs.isCurrent == rhs.isCurrent
    }
}

#Preview {
    SnowStakeView()
        .environmentObject(ThemeManager())
} 