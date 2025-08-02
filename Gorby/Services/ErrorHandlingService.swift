//
//  ErrorHandlingService.swift
//  Gorby
//
//  Created by Mark T on 2025-08-01.
//

import Foundation
import SwiftUI

/// Centralized error handling service for consistent error management across the app
@MainActor
class ErrorHandlingService: ObservableObject {
    static let shared = ErrorHandlingService()
    
    @Published var currentError: AppError?
    @Published var showingErrorAlert = false
    
    private init() {}
    
    /// Handle an error and optionally show it to the user
    func handleError(_ error: Error, context: String = "", showToUser: Bool = true) {
        let appError = AppError.fromError(error, context: context)
        
        // Log error for debugging
        logError(appError)
        
        if showToUser {
            showError(appError)
        }
    }
    
    /// Show an error to the user
    func showError(_ error: AppError) {
        currentError = error
        showingErrorAlert = true
    }
    
    /// Log error for debugging purposes
    private func logError(_ error: AppError) {
        print("🚨 Error[\(error.category)]: \(error.title)")
        print("   Context: \(error.context)")
        print("   Message: \(error.message)")
        if let suggestion = error.suggestion {
            print("   Suggestion: \(suggestion)")
        }
    }
    
    /// Clear current error
    func clearError() {
        currentError = nil
        showingErrorAlert = false
    }
    
    /// Create a retry action for network errors
    func createRetryAction(for action: @escaping () async -> Void) -> (() -> Void) {
        return {
            Task {
                await action()
            }
        }
    }
}

/// Comprehensive error model for the app
struct AppError: Error, Identifiable {
    let id = UUID()
    let category: ErrorCategory
    let title: String
    let message: String
    let context: String
    let suggestion: String?
    let isRetryable: Bool
    
    enum ErrorCategory {
        case network
        case weather
        case location
        case instagram
        case lift
        case webcam
        case storage
        case permission
        case unknown
        
        var icon: String {
            switch self {
            case .network: return "wifi.exclamationmark"
            case .weather: return "cloud.bolt"
            case .location: return "location.slash"
            case .instagram: return "camera.badge.ellipsis"
            case .lift: return "ski"
            case .webcam: return "video.slash"
            case .storage: return "externaldrive.badge.exclamationmark"
            case .permission: return "lock.shield"
            case .unknown: return "exclamationmark.triangle"
            }
        }
        
        var color: Color {
            switch self {
            case .network: return .orange
            case .weather: return .blue
            case .location: return .green
            case .instagram: return .pink
            case .lift: return .purple
            case .webcam: return .red
            case .storage: return .yellow
            case .permission: return .gray
            case .unknown: return .secondary
            }
        }
    }
    
    /// Create AppError from various error types
    static func fromError(_ error: Error, context: String = "") -> AppError {
        
        // Handle InstagramError
        if let instagramError = error as? InstagramError {
            return AppError(
                category: .instagram,
                title: "Instagram Error",
                message: instagramError.localizedDescription,
                context: context,
                suggestion: getInstagramSuggestion(for: instagramError),
                isRetryable: true
            )
        }
        
        // Handle WeatherError
        if let weatherError = error as? WeatherError {
            return AppError(
                category: .weather,
                title: "Weather Data Error",
                message: weatherError.localizedDescription,
                context: context,
                suggestion: "Weather data may be temporarily unavailable. Please try again.",
                isRetryable: true
            )
        }
        
        // Handle APIError
        if let apiError = error as? APIError {
            return AppError(
                category: .network,
                title: "Network Error",
                message: apiError.localizedDescription,
                context: context,
                suggestion: getNetworkSuggestion(for: apiError),
                isRetryable: true
            )
        }
        
        // Handle URLError (network issues)
        if let urlError = error as? URLError {
            return AppError(
                category: .network,
                title: "Connection Error",
                message: getURLErrorMessage(urlError),
                context: context,
                suggestion: getURLErrorSuggestion(urlError),
                isRetryable: true
            )
        }
        
        // Handle DecodingError
        if error is DecodingError {
            return AppError(
                category: .network,
                title: "Data Format Error",
                message: "Received unexpected data format from server",
                context: context,
                suggestion: "This is usually temporary. Please try again in a moment.",
                isRetryable: true
            )
        }
        
        // Generic error
        return AppError(
            category: .unknown,
            title: "Unexpected Error",
            message: error.localizedDescription,
            context: context,
            suggestion: "Please try again. If the problem persists, restart the app.",
            isRetryable: true
        )
    }
    
    // MARK: - Helper Methods
    
    private static func getInstagramSuggestion(for error: InstagramError) -> String {
        switch error {
        case .tokenExpired, .tokenRefreshFailed:
            return "Instagram authorization needs to be renewed. This is normal and happens periodically."
        case .invalidURL, .invalidResponse:
            return "There's a temporary issue with Instagram. Please try again later."
        case .networkError:
            return "Check your internet connection and try again."
        case .decodingError:
            return "Instagram changed their data format. The app may need an update."
        default:
            return "Try again in a few moments. Instagram may be experiencing issues."
        }
    }
    
    private static func getNetworkSuggestion(for error: APIError) -> String {
        switch error {
        case .invalidURL:
            return "There's a configuration issue. Please restart the app."
        case .noData:
            return "The server didn't respond with data. Try again in a moment."
        case .decodingError:
            return "The server response format has changed. The app may need an update."
        case .networkError:
            return "Check your internet connection and try again."
        }
    }
    
    private static func getURLErrorMessage(_ error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet:
            return "No internet connection"
        case .timedOut:
            return "Request timed out"
        case .cannotFindHost:
            return "Cannot reach server"
        case .networkConnectionLost:
            return "Network connection lost"
        case .cannotConnectToHost:
            return "Cannot connect to server"
        default:
            return "Network error occurred"
        }
    }
    
    private static func getURLErrorSuggestion(_ error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet:
            return "Please check your WiFi or cellular connection."
        case .timedOut:
            return "The request took too long. Try again or check your connection."
        case .cannotFindHost, .cannotConnectToHost:
            return "The server might be down. Please try again later."
        case .networkConnectionLost:
            return "Your connection was interrupted. Please try again."
        default:
            return "Check your internet connection and try again."
        }
    }
}

// MARK: - Error Alert View

struct ErrorAlertView: View {
    let error: AppError
    let retryAction: (() -> Void)?
    let dismissAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Error Icon
            Image(systemName: error.category.icon)
                .font(.largeTitle)
                .foregroundColor(error.category.color)
            
            // Title
            Text(error.title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            // Message
            Text(error.message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Suggestion
            if let suggestion = error.suggestion {
                Text(suggestion)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            // Actions
            HStack(spacing: 12) {
                Button("Dismiss") {
                    dismissAction()
                }
                .buttonStyle(.bordered)
                
                if error.isRetryable, let retryAction = retryAction {
                    Button("Try Again") {
                        retryAction()
                        dismissAction()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
    }
}