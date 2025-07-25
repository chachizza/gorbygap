//
//  InstagramService.swift
//  Gorby
//
//  Created by Mark T on 2025-07-19.
//

import Foundation
import SwiftUI

@MainActor
class InstagramService: ObservableObject {
    // App credentials for token refresh
    private let appId = "1041465901389740"
    private let appSecret = "07b347bceebb140e2e75bd8c2f187c78"
    private let userId = "17841400370020314"
    private let mediaId = "17843725936046658"
    
    // Token management
    @Published var isRefreshingToken = false
    private let tokenKey = "instagram_access_token"
    private let tokenExpirationKey = "instagram_token_expiration"
    
    private var currentToken: String {
        get {
            UserDefaults.standard.string(forKey: tokenKey) ?? "EAAOzNS0ZAF6wBPCE7ILXFiBItXRezOkGPcLEoG8ZBTdoS2StqZB1nsMdRXqrHjwsSJqXdbVpgbkNmyKt7sIsZBUiyDSN97GRe5mzyZCN4jeK6WZBacxIC2OUKLWpBk37wHOpcf2ZCvw4aYLQDi4SZBqyfXjzAaaawiO3hZABiz6Tzboo4of7Kv0Se2364MygCTsWL97gUxVLObXJT"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
    
    private var tokenExpiration: Date {
        get {
            UserDefaults.standard.object(forKey: tokenExpirationKey) as? Date ?? Date()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenExpirationKey)
        }
    }
    
    func fetchInstagramPosts() async throws -> [InstagramPost] {
        // Check if token needs refresh (refresh 5 days before expiration)
        let refreshThreshold = Calendar.current.date(byAdding: .day, value: -5, to: tokenExpiration) ?? Date()
        
        if Date() > refreshThreshold {
            print("🔄 Instagram API: Token needs refresh (expires: \(tokenExpiration))")
            try await refreshTokenIfNeeded()
        }
        
        let urlString = "https://graph.facebook.com/v19.0/\(mediaId)/recent_media?user_id=\(userId)&fields=id,caption,media_type,media_url,permalink&access_token=\(currentToken)"
        
        print("🔄 Instagram API: Fetching posts from URL...")
        
        guard let url = URL(string: urlString) else {
            print("❌ Instagram API: Invalid URL")
            throw InstagramError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Instagram API: Invalid HTTP response")
                throw InstagramError.invalidResponse
            }
            
            print("🌐 Instagram API: Response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 190 {
                // Token expired - try to refresh immediately
                print("🔄 Instagram API: Token expired, attempting emergency refresh...")
                try await refreshTokenIfNeeded()
                // Retry the request with new token
                return try await fetchInstagramPosts()
            }
            
            if httpResponse.statusCode != 200 {
                if let errorData = String(data: data, encoding: .utf8) {
                    print("❌ Instagram API Error Response: \(errorData)")
                }
                throw InstagramError.invalidResponse
            }
            
            let instagramResponse = try JSONDecoder().decode(InstagramResponse.self, from: data)
            
            print("✅ Instagram API: Successfully decoded \(instagramResponse.data.count) items")
            
            let posts = instagramResponse.data.compactMap { mediaItem -> InstagramPost? in
                // Only include image posts (exclude videos for now)
                guard mediaItem.media_type == "IMAGE" else { 
                    print("📹 Skipping non-image post: \(mediaItem.media_type)")
                    return nil 
                }
                
                return InstagramPost(
                    id: mediaItem.id,
                    username: "gorbygapp", // Your Instagram handle
                    imageUrl: mediaItem.media_url,
                    caption: mediaItem.caption ?? "",
                    permalink: mediaItem.permalink
                )
            }
            
            print("📸 Instagram API: Returning \(posts.count) image posts")
            return posts
            
        } catch let decodingError as DecodingError {
            print("❌ Instagram API: JSON decoding error: \(decodingError)")
            throw InstagramError.decodingError(decodingError.localizedDescription)
        } catch {
            print("❌ Instagram API: Network error: \(error)")
            throw InstagramError.networkError(error.localizedDescription)
        }
    }
    
    private func refreshTokenIfNeeded() async throws {
        guard !isRefreshingToken else {
            print("🔄 Instagram API: Token refresh already in progress")
            return
        }
        
        isRefreshingToken = true
        defer { isRefreshingToken = false }
        
        print("🔄 Instagram API: Starting token refresh...")
        
        let urlString = "https://graph.facebook.com/v19.0/oauth/access_token?grant_type=fb_exchange_token&client_id=\(appId)&client_secret=\(appSecret)&fb_exchange_token=\(currentToken)"
        
        guard let url = URL(string: urlString) else {
            print("❌ Instagram API: Invalid refresh URL")
            throw InstagramError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Instagram API: Invalid refresh response")
            throw InstagramError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorData = String(data: data, encoding: .utf8) {
                print("❌ Instagram API: Token refresh failed: \(errorData)")
            }
            throw InstagramError.tokenRefreshFailed
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        // Update stored token and expiration
        currentToken = tokenResponse.access_token
        tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
        
        print("✅ Instagram API: Token refreshed successfully! New expiration: \(tokenExpiration)")
    }
    
    // Public method to manually trigger token refresh (useful for testing)
    func manualRefreshToken() async throws {
        try await refreshTokenIfNeeded()
    }
    
    // Public method to check token status
    func getTokenStatus() -> (isValid: Bool, expiresAt: Date, daysUntilExpiration: Int) {
        let now = Date()
        let isValid = now < tokenExpiration
        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: now, to: tokenExpiration).day ?? 0
        
        return (isValid: isValid, expiresAt: tokenExpiration, daysUntilExpiration: daysUntilExpiration)
    }
    
    // Initialize with a new token (call this once when you first set up the service)
    func initializeToken(_ token: String, expiresIn: Int) {
        currentToken = token
        tokenExpiration = Date().addingTimeInterval(TimeInterval(expiresIn))
        print("🔑 Instagram API: Token initialized. Expires: \(tokenExpiration)")
    }
}

// MARK: - Instagram API Models
struct InstagramResponse: Codable {
    let data: [InstagramMediaItem]
}

struct InstagramMediaItem: Codable {
    let id: String
    let caption: String?
    let media_type: String
    let media_url: String
    let permalink: String
}

struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
}

// MARK: - App Models
struct InstagramPost: Identifiable {
    let id: String
    let username: String
    let imageUrl: String
    let caption: String
    let permalink: String
}

// MARK: - Errors
enum InstagramError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError(String)
    case networkError(String)
    case tokenExpired
    case tokenRefreshFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid Instagram URL"
        case .invalidResponse:
            return "Invalid response from Instagram"
        case .noData:
            return "No Instagram data available"
        case .decodingError(let error):
            return "JSON decoding error: \(error)"
        case .networkError(let error):
            return "Network error: \(error)"
        case .tokenExpired:
            return "Instagram token expired. Please refresh."
        case .tokenRefreshFailed:
            return "Failed to refresh Instagram token."
        }
    }
} 