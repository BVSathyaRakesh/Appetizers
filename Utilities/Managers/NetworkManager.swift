//
//  NetworkManager.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/05/25.
//

import UIKit

// MARK: - Network Configuration
struct NetworkConfiguration {
    let baseURL: String
    let timeoutInterval: TimeInterval
    let cachePolicy: URLRequest.CachePolicy
    
    static let `default` = NetworkConfiguration(
        baseURL: "http://localhost:3000/swiftui-fundamentals/",
        timeoutInterval: 30.0,
        cachePolicy: .useProtocolCachePolicy
    )
}

// MARK: - Protocols for Dependency Injection (ISP Compliant)

/// Protocol for API data fetching operations
protocol APIClientProtocol {
    func fetchRequest<T: Decodable>(from endpoint: String, responseType: T.Type) async throws -> T
}

/// Protocol for image downloading operations  
protocol ImageDownloadProtocol {
    func downloadImage(from urlString: String) async throws -> UIImage?
}

/// Composed protocol for components that need both API and image operations
protocol NetworkManagerProtocol: APIClientProtocol, ImageDownloadProtocol {}

// MARK: - NetworkManager Implementation
final class NetworkManager: NetworkManagerProtocol {
    
    // MARK: - Properties
    static let shared = NetworkManager()
    
    private let httpClient: HTTPClientProtocol
    private let jsonDecoder: JSONDecoderServiceProtocol
    private let imageDownloader: ImageDownloaderProtocol
    private let urlBuilder: URLBuilderProtocol
    
    // MARK: - Initialization
    init(
        httpClient: HTTPClientProtocol = HTTPClient(),
        jsonDecoder: JSONDecoderServiceProtocol = JSONDecoderService(),
        imageDownloader: ImageDownloaderProtocol = ImageDownloader(),
        urlBuilder: URLBuilderProtocol = URLBuilder()
    ) {
        self.httpClient = httpClient
        self.jsonDecoder = jsonDecoder
        self.imageDownloader = imageDownloader
        self.urlBuilder = urlBuilder
    }
    
    // MARK: - Public Methods
    
    /// Generic method for fetching any decodable type from API
    func fetchRequest<T: Decodable>(from endpoint: String, responseType: T.Type) async throws -> T {
        let url = try urlBuilder.buildURL(from: endpoint)
        let data = try await httpClient.performRequest(url: url)
        return try jsonDecoder.decode(responseType, from: data)
    }
  
    
    func downloadImage(from urlString: String) async throws -> UIImage? {
        return try await imageDownloader.downloadImage(from: urlString)
    }
}

