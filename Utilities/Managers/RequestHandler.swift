//
//  HTTPClient.swift
//  Appetizers
//
//  Created by Sathya Kumar on 27/09/25.
//

import Foundation


// MARK: - HTTP Client Protocol
protocol HTTPClientProtocol {
    func performRequest(url: URL) async throws -> Data
}

// MARK: - URLSession Protocol for Testing
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

// MARK: - HTTP Client Implementation
final class HTTPClient: HTTPClientProtocol {
    private let session: URLSessionProtocol
    private let configuration: NetworkConfiguration
    private let responseValidator: ResponseValidatorProtocol
    
    init(
        session: URLSessionProtocol = URLSession.shared,
        configuration: NetworkConfiguration = .default,
        responseValidator: ResponseValidatorProtocol = ResponseValidator()
    ) {
        self.session = session
        self.configuration = configuration
        self.responseValidator = responseValidator
    }
    
    func performRequest(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.timeoutInterval = configuration.timeoutInterval
        request.cachePolicy = configuration.cachePolicy
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            try responseValidator.validate(response)
            return data
        } catch {
            if error is APError {
                throw error
            } else {
                throw APError.unableToComplete
            }
        }
    }
}
