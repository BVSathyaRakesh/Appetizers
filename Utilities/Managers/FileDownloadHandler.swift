//
//  ImageHandler.swift
//  Appetizers
//
//  Created by Sathya Kumar on 27/09/25.
//

import Foundation
import UIKit



// MARK: - Image Cache Protocol
protocol ImageCacheProtocol {
    func image(for key: String) -> UIImage?
    func setImage(_ image: UIImage, for key: String, cost: Int)
}

// MARK: - Image Cache Implementation
final class ImageCache: ImageCacheProtocol {
    private let cache = NSCache<NSString, UIImage>()
    
    init(countLimit: Int = 100, totalCostLimit: Int = 50 * 1024 * 1024) {
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit
    }
    
    func image(for key: String) -> UIImage? {
        return cache.object(forKey: NSString(string: key))
    }
    
    func setImage(_ image: UIImage, for key: String, cost: Int) {
        cache.setObject(image, forKey: NSString(string: key), cost: cost)
    }
}

// MARK: - Image Downloader Protocol
protocol ImageDownloaderProtocol {
    func downloadImage(from urlString: String) async throws -> UIImage?
}

// MARK: - Image Downloader Implementation
final class ImageDownloader: ImageDownloaderProtocol {
    private let httpClient: HTTPClientProtocol
    private let imageCache: ImageCacheProtocol
    
    init(
        httpClient: HTTPClientProtocol = HTTPClient(),
        imageCache: ImageCacheProtocol = ImageCache()
    ) {
        self.httpClient = httpClient
        self.imageCache = imageCache
    }
    
    func downloadImage(from urlString: String) async throws -> UIImage? {
        // Check cache first
        if let cachedImage = imageCache.image(for: urlString) {
            return cachedImage
        }
        
        // Download image
        guard let url = URL(string: urlString) else {
            throw APError.invalidURL
        }
        
        let data = try await httpClient.performRequest(url: url)
        
        // Create image
        guard let image = UIImage(data: data) else {
            throw APError.invalidData
        }
        
        // Cache image with cost (approximate memory usage)
        imageCache.setImage(image, for: urlString, cost: data.count)
        
        return image
    }
}
