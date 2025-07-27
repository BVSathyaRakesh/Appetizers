//
//  MockNetworkManager.swift
//  AppetizersTests
//
//  Mock implementation for testing
//

import UIKit
@testable import Appetizers

class MockNetworkManager: NetworkManagerProtocol {
    
    // MARK: - Test Configuration
    var shouldReturnError = false
    var errorToReturn: APError = .invalidData
    var appetizersToReturn: [Appetizer] = []
    
    // MARK: - Call Tracking
    var fetchAppetizersCalled = false
    var fetchAppetizersCallCount = 0
    
    // MARK: - NetworkManagerProtocol Implementation
    func fetchAppetizers() async throws -> [Appetizer] {
        fetchAppetizersCalled = true
        fetchAppetizersCallCount += 1
        
        if shouldReturnError {
            throw errorToReturn
        }
        
        return appetizersToReturn
    }
    
    func downloadImages(imageURL urlString: String, completed: @escaping (UIImage?) -> Void) {
        // For testing, we can return a test image or nil
        completed(nil)
    }
    
    // MARK: - Test Helper Methods
    func setupSuccessResponse(with appetizers: [Appetizer]) {
        shouldReturnError = false
        appetizersToReturn = appetizers
    }
    
    func setupErrorResponse(error: APError) {
        shouldReturnError = true
        errorToReturn = error
    }
    
    func reset() {
        shouldReturnError = false
        appetizersToReturn = []
        fetchAppetizersCalled = false
        fetchAppetizersCallCount = 0
    }
}

// MARK: - Test Data Factory
struct TestDataFactory {
    static func createTestAppetizer(id: Int = 1) -> Appetizer {
        return Appetizer(
            id: id,
            name: "Test Appetizer \(id)",
            description: "Test description for appetizer \(id)",
            price: Double(id) * 2.99,
            imageURL: "https://test.com/image\(id).jpg",
            calories: 100 + (id * 50),
            protein: 10 + id,
            carbs: 15 + id
        )
    }
    
    static func createTestAppetizers(count: Int = 3) -> [Appetizer] {
        return (1...count).map { createTestAppetizer(id: $0) }
    }
    
    static let sampleAppetizer = createTestAppetizer()
    static let sampleAppetizers = createTestAppetizers()
} 