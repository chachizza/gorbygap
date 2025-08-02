//
//  Configuration.swift
//  Gorby
//
//  Created by Mark T on 2025-08-01.
//

import Foundation

/// Secure configuration manager for API keys and sensitive data
class Configuration {
    static let shared = Configuration()
    
    private init() {}
    
    // MARK: - Instagram Configuration
    
    /// Instagram App ID - Move to build configuration or environment
    var instagramAppId: String {
        // TODO: Move to build settings or secure configuration
        // For now, read from Info.plist or environment
        return Bundle.main.object(forInfoDictionaryKey: "INSTAGRAM_APP_ID") as? String 
            ?? ProcessInfo.processInfo.environment["INSTAGRAM_APP_ID"] 
            ?? "1041465901389740" // Fallback - should be removed in production
    }
    
    /// Instagram App Secret - Should be moved to secure storage
    var instagramAppSecret: String {
        // TODO: Move to secure keychain storage or server-side
        // For now, read from Info.plist or environment
        return Bundle.main.object(forInfoDictionaryKey: "INSTAGRAM_APP_SECRET") as? String 
            ?? ProcessInfo.processInfo.environment["INSTAGRAM_APP_SECRET"] 
            ?? "07b347bceebb140e2e75bd8c2f187c78" // Fallback - should be removed in production
    }
    
    /// Instagram User ID
    var instagramUserId: String {
        return Bundle.main.object(forInfoDictionaryKey: "INSTAGRAM_USER_ID") as? String 
            ?? ProcessInfo.processInfo.environment["INSTAGRAM_USER_ID"] 
            ?? "17841400370020314" // Fallback
    }
    
    /// Instagram Media ID
    var instagramMediaId: String {
        return Bundle.main.object(forInfoDictionaryKey: "INSTAGRAM_MEDIA_ID") as? String 
            ?? ProcessInfo.processInfo.environment["INSTAGRAM_MEDIA_ID"] 
            ?? "17843725936046658" // Fallback
    }
    
    // MARK: - Backend Configuration
    
    /// Backend API base URL
    var backendBaseURL: String {
        #if DEBUG
        return "https://gorby-backend.fly.dev/api"
        #else
        return "https://gorby-backend.fly.dev/api"
        #endif
    }
    
    // MARK: - API Endpoints
    
    /// Lift status API endpoint
    var liftStatusEndpoint: String {
        return "\(backendBaseURL)/lifts"
    }
    
    /// Webcam API endpoint  
    var webcamEndpoint: String {
        return "\(backendBaseURL)/webcams"
    }
    
    /// All data endpoint
    var allDataEndpoint: String {
        return "\(backendBaseURL)/all"
    }
    
    // MARK: - Security Helpers
    
    /// Check if we're running in a secure environment
    var isSecureEnvironment: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
    
    /// Validate that critical credentials are not using fallback values
    func validateCredentials() -> [String] {
        var warnings: [String] = []
        
        if instagramAppSecret == "07b347bceebb140e2e75bd8c2f187c78" {
            warnings.append("Instagram App Secret is using fallback value - move to secure storage")
        }
        
        if instagramAppId == "1041465901389740" {
            warnings.append("Instagram App ID is using fallback value - move to build configuration")
        }
        
        return warnings
    }
}

// MARK: - Configuration Protocol for Testing

protocol ConfigurationProtocol {
    var instagramAppId: String { get }
    var instagramAppSecret: String { get }
    var instagramUserId: String { get }
    var instagramMediaId: String { get }
    var backendBaseURL: String { get }
}

extension Configuration: ConfigurationProtocol {}