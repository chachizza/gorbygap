import Foundation
import Combine

@MainActor
class WebcamService: ObservableObject {
    static let shared = WebcamService()
    
    @Published var webcams: [WebcamData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "http://10.0.0.238:3001/api"
    
    private init() {
        // Start with an initial fetch
        Task {
            await fetchWebcams()
        }
    }
    
    func fetchWebcams() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        guard let url = URL(string: "\(baseURL)/webcams") else {
            errorMessage = "Invalid URL"
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(WebcamResponse.self, from: data)
            
            // Update on main thread
            await MainActor.run {
                self.webcams = response.webcams
                self.lastUpdated = Date()
                self.errorMessage = nil
                
                print("✅ WebcamService: Loaded \(response.webcams.count) live webcams")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to fetch webcams: \(error.localizedDescription)"
                print("❌ WebcamService Error: \(error)")
                
                // Fallback: Keep existing data if available
                if webcams.isEmpty {
                    print("⚠️ WebcamService: No cached data available")
                }
            }
        }
    }
    
    func refreshWebcams() async {
        await fetchWebcams()
    }
}

// MARK: - Response Models
struct WebcamResponse: Codable {
    let lastUpdated: String
    let source: String
    let webcamCount: Int
    let webcams: [WebcamData]
} 