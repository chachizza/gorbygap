//
//  WebcamView.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import SwiftUI

// Simple image cache to prevent reloading
class ImageCache {
    static let shared = ImageCache()
    private var cache: [String: UIImage] = [:]
    
    func getImage(for url: String) -> UIImage? {
        return cache[url]
    }
    
    func setImage(_ image: UIImage, for url: String) {
        cache[url] = image
    }
}

struct WebcamView: View {
    @StateObject private var viewModel = WebcamViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    // Header with last updated
                    HStack {
                        Spacer()
                        
                        if !viewModel.lastUpdated.isEmpty {
                            Text("Updated \(viewModel.lastUpdated)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Webcam list
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.webcams) { webcam in
                            WebcamCard(webcam: webcam)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Webcams")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WebcamCard: View {
    let webcam: WebcamData
    @EnvironmentObject var themeManager: ThemeManager
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var hasError = false
    @State private var retryCount = 0
    @State private var hasLoadedOnce = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Webcam image
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(maxWidth: .infinity, maxHeight: 240)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else if hasError {
                    VStack {
                        Text("Failed to load")
                            .foregroundColor(.red)
                            .font(.caption)
                        if retryCount < 3 {
                            Button("Retry") {
                                loadImage()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top, 4)
                        }
                    }
                } else if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 240)
                        .clipped()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 240)
            .clipped()
            .cornerRadius(12)
            
            // Webcam info
            HStack {
                Text(webcam.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if let elevation = webcam.elevation {
                    Text("\(elevation)m")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(elevationColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(themeManager.currentTheme.cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .frame(maxWidth: .infinity)
        .onAppear {
            if !hasLoadedOnce {
                loadImage()
            }
        }
    }
    
    private var elevationColor: Color {
        switch webcam.name {
        case "Whistler Peak":
            return Color(red: 1.0, green: 0.2, blue: 0.8) // Bright pink/magenta
        case "Glacier":
            return Color(red: 0.6, green: 0.2, blue: 1.0) // Purple
        case "Roundhouse":
            return Color(red: 1.0, green: 0.5, blue: 0.0) // Orange
        case "Rendezvous":
            return Color(red: 0.0, green: 0.7, blue: 0.8) // Turquoise
        case "Whistler Village":
            return Color(red: 1.0, green: 0.4, blue: 0.8) // Lighter pink
        case "Blackcomb Base":
            return Color(red: 0.2, green: 0.8, blue: 0.4) // Green
        case "Creekside":
            return Color(red: 0.6, green: 0.2, blue: 1.0) // Purple
        default:
            return Color(red: 0.6, green: 0.2, blue: 1.0) // Default purple
        }
    }
    
    private func loadImage() {
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(for: webcam.snapshotUrl) {
            self.image = cachedImage
            self.isLoading = false
            self.hasError = false
            self.hasLoadedOnce = true
            return
        }
        
        isLoading = true
        hasError = false
        
        guard let url = URL(string: webcam.snapshotUrl) else {
            hasError = true
            isLoading = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("Error loading image for \(webcam.name): \(error.localizedDescription)")
                    hasError = true
                    retryCount += 1
                    return
                }
                
                guard let data = data, let loadedImage = UIImage(data: data) else {
                    print("Invalid image data for \(webcam.name)")
                    hasError = true
                    retryCount += 1
                    return
                }
                
                // Cache the image
                ImageCache.shared.setImage(loadedImage, for: webcam.snapshotUrl)
                
                self.image = loadedImage
                self.hasError = false
                self.retryCount = 0
                self.hasLoadedOnce = true
            }
        }
        
        task.resume()
    }
}

#Preview {
    WebcamView()
        .environmentObject(ThemeManager())
} 