//
//  LocationService.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import Foundation
import CoreLocation
// import Combine // Removed - no longer needed for lift updates

@MainActor
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isOnMountain = false
    // @Published var nearestLift: LiftData? // Removed - Lift functionality cleared
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    // private var cancellables = Set<AnyCancellable>() // Removed - no longer needed for lift updates
    
    // Whistler/Blackcomb coordinates
    private let whistlerVillageCenter = CLLocation(latitude: 50.1163, longitude: -122.9574)
    private let mountainRadius: CLLocationDistance = 10000 // 10km radius
    
    nonisolated override init() {
        super.init()
        Task { @MainActor in
            setupLocationManager()
            // observeLiftUpdates() // Removed - Lift functionality cleared
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50 // Update every 50 meters
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // private func observeLiftUpdates() {
    //     LiftStatusService.shared.$lifts
    //         .sink { [weak self] lifts in
    //             Task { @MainActor in
    //                 self?.updateNearestLift(with: lifts)
    //             }
    //         }
    //         .store(in: &cancellables)
    // }
    
    func requestLocationPermission() {
        guard authorizationStatus == .notDetermined else { return }
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            errorMessage = "Location permission required"
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    // private func updateNearestLift(with lifts: [LiftData]) {
    //     guard let currentLocation = currentLocation else {
    //         nearestLift = nil
    //         return
    //     }
    //     
    //     let sortedLifts = lifts.sorted { lift1, lift2 in
    //         let distance1 = currentLocation.distance(from: whistlerVillageCenter)
    //         let distance2 = currentLocation.distance(from: whistlerVillageCenter)
    //         return distance1 < distance2
    //     }
    //     
    //     nearestLift = sortedLifts.first
    // }
    
    private func checkIfOnMountain(_ location: CLLocation) {
        let distanceToWhistler = location.distance(from: whistlerVillageCenter)
        isOnMountain = distanceToWhistler <= mountainRadius
        
        // if !isOnMountain {
        //     nearestLift = nil
        // }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            currentLocation = location
            checkIfOnMountain(location)
            errorMessage = nil
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            errorMessage = "Location error: \(error.localizedDescription)"
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            authorizationStatus = status
            
            switch status {
            case .denied, .restricted:
                errorMessage = "Location access denied"
                stopLocationUpdates()
            case .authorizedWhenInUse, .authorizedAlways:
                errorMessage = nil
                startLocationUpdates()
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
}

// MARK: - Mountain Location Helpers

extension LocationService {
    var distanceFromVillage: String? {
        guard let location = currentLocation else { return nil }
        
        let distance = location.distance(from: whistlerVillageCenter)
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.numberFormatter.maximumFractionDigits = 1
        
        if distance < 1000 {
            let measurement = Measurement(value: distance, unit: UnitLength.meters)
            return formatter.string(from: measurement)
        } else {
            let measurement = Measurement(value: distance / 1000, unit: UnitLength.kilometers)
            return formatter.string(from: measurement)
        }
    }
    
    var elevationString: String? {
        guard let location = currentLocation else { return nil }
        
        let elevation = location.altitude
        if elevation > 0 {
            return String(format: "%.0f m", elevation)
        }
        return nil
    }
} 