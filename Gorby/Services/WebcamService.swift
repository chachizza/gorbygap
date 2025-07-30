import Foundation
import Combine

@MainActor
class WebcamService: ObservableObject {
    static let shared = WebcamService()
    
    @Published var webcams: [WebcamData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    private var refreshTimer: Timer?
    
    private init() {
        loadWebcams()
        startAutoRefresh()
    }
    
    // MARK: - Webcam Data
    
    private func loadWebcams() {
        webcams = [
            WebcamData(name: "Whistler Peak", cameraId: "whistlerpeak", location: "Peak", elevation: 2182),
            WebcamData(name: "Glacier", cameraId: "whistlerglacier", location: "Glacier", elevation: 1650),
            WebcamData(name: "Roundhouse", cameraId: "whistlerroundhouse", location: "Mid-Mountain", elevation: 1856),
            WebcamData(name: "Rendezvous", cameraId: "whistlerblackcomb", location: "Rendezvous", elevation: 1860),
            WebcamData(name: "Whistler Village", cameraId: "whistlervillagefitz", location: "Village", elevation: 700),
            WebcamData(name: "Blackcomb Base", cameraId: "whistlervillage", location: "Base", elevation: 675),
            WebcamData(name: "Creekside", cameraId: "whistlercreekside", location: "Creekside", elevation: 850)
        ]
        lastUpdated = Date()
    }
    
    // MARK: - Auto Refresh
    
    private func startAutoRefresh() {
        // Refresh every 5 minutes
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            Task { @MainActor in
                await self.refreshWebcams()
            }
        }
    }
    
    func refreshWebcams() async {
        lastUpdated = Date()
        // Update timestamps for all webcams
        for i in 0..<webcams.count {
            webcams[i] = WebcamData(
                name: webcams[i].name,
                cameraId: webcams[i].cameraId,
                location: webcams[i].location,
                elevation: webcams[i].elevation
            )
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
} 