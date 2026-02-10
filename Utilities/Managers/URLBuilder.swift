//
//  URLBuilder.swift
//  Appetizers
//
//  Created by Sathya Kumar on 27/09/25.
//

import Foundation

// MARK: - URL Builder Protocol
protocol URLBuilderProtocol {
    func buildURL(from endpoint: String) throws -> URL
}

// MARK: - URL Builder Implementation
final class URLBuilder: URLBuilderProtocol {
    private let configuration: NetworkConfiguration
    
    init(configuration: NetworkConfiguration = .default) {
        self.configuration = configuration
    }
    
    func buildURL(from endpoint: String) throws -> URL {
        let urlString = configuration.baseURL + endpoint
        guard let url = URL(string: urlString) else {
            throw APError.invalidURL
        }
        return url
    }
}
