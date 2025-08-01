//
//  ImageCache.swift
//  Gorby
//
//  Created by Mark T on 2025-07-17.
//

import UIKit

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