//
//  EnvironmentManager.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/09/25.
//

import Foundation
import SwiftUI

// MARK: - Service Container
class AppetizerServiceContainer: ObservableObject {
    @Published var service: AppetizerServiceProtocol
    
    init() {
        // Check environment variables for service type (set by UI tests)
        let serviceType = ProcessInfo.processInfo.environment["APPETIZER_SERVICE_TYPE"] ?? "PRODUCTION"
        
        switch serviceType {
        case "MOCK_SUCCESS":
            #if DEBUG
            self.service = MockAppetizerService(simulateError: nil)
            #else
            self.service = AppetizerService()
            #endif
            
        case "MOCK_ERROR":
            #if DEBUG
            let errorType = ProcessInfo.processInfo.environment["ERROR_TYPE"] ?? "UNABLE_TO_COMPLETE"
            let error = APError.from(string: errorType)
            self.service = MockAppetizerService(simulateError: error)
            #else
            self.service = AppetizerService()
            #endif
            
        case "MOCK_SERVICE", "SLOW_SERVICE", "UNRELIABLE_SERVICE":
            #if DEBUG
            self.service = MockAppetizerService(simulateError: nil)
            #else
            self.service = AppetizerService()
            #endif
            
        default: // "PRODUCTION" or any other value
            self.service = AppetizerService()
        }
    }
    
    // MARK: - Runtime Dependency Injection (for advanced scenarios)
    func injectService(_ newService: AppetizerServiceProtocol) {
        self.service = newService
    }
}

// MARK: - Mock Service for UI Testing
#if DEBUG
class MockAppetizerService: AppetizerServiceProtocol {
    private let errorToSimulate: APError?
    
    init(simulateError: APError? = nil) {
        self.errorToSimulate = simulateError
    }
    
    func fetchAppetizers() async throws -> AppetizerResponse {
        // Small delay to simulate network
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // If we should simulate an error, throw it
        if let error = errorToSimulate {
            throw error
        }
        
        // Otherwise return mock data
        return AppetizerResponse.mock
    }
}
#endif
