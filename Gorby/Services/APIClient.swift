//
//  APIClient.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import Combine

class APIClient: ObservableObject {
    static let shared = APIClient()
    
    private let baseURL = "https://api.whistler.com/v1"
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Generic Request Method
    
    private func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil
    ) -> AnyPublisher<T, Error> {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("WhistlerRide/1.0", forHTTPHeaderField: "User-Agent")
        
        if let body = body {
            request.httpBody = body
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Weather Endpoints
    
    func getCurrentWeather() -> AnyPublisher<WeatherData, Error> {
        return request(endpoint: "/weather/current")
    }
    
    func getForecast() -> AnyPublisher<[DayForecast], Error> {
        return request(endpoint: "/weather/forecast")
    }
    
    func getCurrentConditions() -> AnyPublisher<CurrentConditions, Error> {
        return request(endpoint: "/weather/conditions")
    }
    
    // MARK: - Lift Endpoints (Removed - Lift functionality cleared)
    
    // func getLiftStatus() -> AnyPublisher<LiftStatusResponse, Error> {
    //     return request(endpoint: "/lifts/status")
    // }
    // 
    // func getLiftDetails(liftId: String) -> AnyPublisher<LiftData, Error> {
    //     return request(endpoint: "/lifts/\(liftId)")
    // }
    
    // MARK: - Webcam Endpoints
    
    func getWebcams() -> AnyPublisher<[WebcamData], Error> {
        return request(endpoint: "/webcams")
    }
    
    func getWebcamImage(webcamId: String) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: "\(baseURL)/webcams/\(webcamId)/image") else {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .mapError { $0 as Error }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Snow Stake Endpoints
    
    func getSnowStakeData() -> AnyPublisher<SnowStakeResponse, Error> {
        return request(endpoint: "/snow-stake")
    }
    
    func getSnowStakeHistory() -> AnyPublisher<[HistoricalSnowImage], Error> {
        return request(endpoint: "/snow-stake/history")
    }
    
    // MARK: - Temperature Endpoints
    
    func getTemperatureStations() -> AnyPublisher<TemperatureResponse, Error> {
        return request(endpoint: "/temperature/stations")
    }
    
    func getStationDetails(stationId: String) -> AnyPublisher<TemperatureStation, Error> {
        return request(endpoint: "/temperature/\(stationId)")
    }
}

// MARK: - Supporting Types

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

// MARK: - Response Models

// struct LiftStatusResponse: Codable { // Removed - Lift functionality cleared
//     let whistlerLifts: [LiftData]
//     let blackcombLifts: [LiftData]
//     let lastUpdated: Date
// }

struct SnowStakeResponse: Codable {
    let currentDepth: Int
    let lastUpdated: String
    let imageUrl: String
    let historicalData: [SnowDepthDataPoint]
}

struct TemperatureResponse: Codable {
    let stations: [TemperatureStation]
    let lastUpdated: Date
} 