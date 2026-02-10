//
//  AppetizerService.swift
//  Appetizers
//
//  Created by Sathya Kumar on 27/09/25.
//

import Foundation

// MARK: - Appetizer Service Protocol
protocol AppetizerServiceProtocol {
    func fetchAppetizers() async throws -> AppetizerResponse
}

// MARK: - Appetizer Service Implementation
final class AppetizerService: AppetizerServiceProtocol {
    
    private let appetizerURL =  "appetizers"
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = NetworkManager.shared) {
        self.apiClient = apiClient
    }
    
    func fetchAppetizers() async throws -> AppetizerResponse {
        return try await apiClient.fetchRequest(from: appetizerURL, responseType: AppetizerResponse.self)
    }
}
