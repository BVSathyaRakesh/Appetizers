//
//  NetworkManagerExampleTests.swift
//  AppetizersTests
//
//  Created by Sathya Kumar on 29/09/25.
//

import XCTest
@testable import Appetizers

/// Example tests demonstrating how to use the mock server utilities
/// These tests serve as documentation and examples for other developers
final class NetworkManagerExampleTests: XCTestCase {
    
    var networkManager: NetworkManager!
    
    override func setUpWithError() throws {
        super.setUp()
        // Setup network manager with mock server
        networkManager = setupMockServer()
    }
    
    override func tearDownWithError() throws {
        // Clean up mock configurations
        MockServerManager.shared.clearAllMockResponses()
        networkManager = nil
        super.tearDown()
    }
    
    // MARK: - Basic Usage Examples
    
    func testExample_BasicSuccessResponse() async throws {
        // EXAMPLE: How to test a successful API response
        
        // Given - Setup a successful response using the builder pattern
        createTestScenario()
            .withSuccessfulAppetizers()
            .build()
        
        // When - Make the network request
        let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
        
        // Then - Verify the result
        XCTAssertEqual(result.request.count, 3) // AppetizerResponse.mock has 3 items
        XCTAssertEqual(result.request.first?.name, "Spring Rolls")
    }
    
    func testExample_BasicErrorResponse() async throws {
        // EXAMPLE: How to test error scenarios
        
        // Given - Setup a server error response
        createTestScenario()
            .withFailedAppetizers(statusCode: 500)
            .build()
        
        // When & Then - Verify error is thrown
        do {
            _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
            XCTFail("Expected error to be thrown")
        } catch let error as APError {
            XCTAssertEqual(error, APError.unableToComplete)
        }
    }
    
    // MARK: - Custom Response Examples
    
    func testExample_CustomAppetizerData() async throws {
        // EXAMPLE: How to test with custom data
        
        // Given - Create custom test data
        let customAppetizers = [
            TestDataFactory.createAppetizer(
                id: 100,
                name: "Custom Appetizer",
                description: "A test appetizer for demonstration",
                price: 15.99
            ),
            TestDataFactory.createAppetizer(
                id: 101,
                name: "Another Custom Appetizer",
                description: "Another test appetizer",
                price: 12.50
            )
        ]
        
        let customResponse = TestDataFactory.createAppetizerResponse(appetizers: customAppetizers)
        
        // Setup mock response with custom data
        createTestScenario()
            .withCustomResponse(
                for: "appetizers",
                response: MockResponse.success(customResponse)
            )
            .build()
        
        // When
        let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
        
        // Then
        XCTAssertEqual(result.request.count, 2)
        XCTAssertEqual(result.request.first?.name, "Custom Appetizer")
        XCTAssertEqual(result.request.first?.price, 15.99)
    }
    
    func testExample_NetworkDelaySimulation() async throws {
        // EXAMPLE: How to test network delays
        
        // Given - Setup response with delay
        createTestScenario()
            .withSuccessfulAppetizers(delay: 1.0) // 1 second delay
            .build()
        
        let startTime = Date()
        
        // When
        let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Then
        XCTAssertGreaterThanOrEqual(duration, 1.0, "Should take at least 1 second")
        XCTAssertEqual(result.request.count, 3)
    }
    
    // MARK: - Multiple Endpoint Examples
    
    func testExample_MultipleEndpoints() async throws {
        // EXAMPLE: How to configure multiple endpoints
        
        // Given - Setup different responses for different endpoints
        let menuResponse = TestDataFactory.createAppetizerResponse(count: 5)
        let specialsResponse = TestDataFactory.createAppetizerResponse(count: 2)
        
        createTestScenario()
            .withCustomResponse(
                for: "menu",
                response: MockResponse.success(menuResponse)
            )
            .withCustomResponse(
                for: "specials",
                response: MockResponse.success(specialsResponse)
            )
            .build()
        
        // When - Make requests to different endpoints
        let menuResult = try await networkManager.fetchRequest(from: "menu", responseType: AppetizerResponse.self)
        let specialsResult = try await networkManager.fetchRequest(from: "specials", responseType: AppetizerResponse.self)
        
        // Then
        XCTAssertEqual(menuResult.request.count, 5)
        XCTAssertEqual(specialsResult.request.count, 2)
    }
    
    // MARK: - Error Scenario Examples
    
    func testExample_DifferentErrorTypes() async throws {
        // EXAMPLE: How to test different types of errors
        
        // Test network timeout
        createTestScenario()
            .withNetworkTimeout(for: "appetizers")
            .build()
        
        do {
            _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
            XCTFail("Expected timeout error")
        } catch {
            // Expected timeout error
        }
        
        // Clear and test invalid JSON
        createTestScenario()
            .clear()
        
        createTestScenario()
            .withInvalidJSON(for: "appetizers")
            .build()
        
        do {
            _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
            XCTFail("Expected JSON parsing error")
        } catch let error as APError {
            XCTAssertEqual(error, APError.invalidData)
        }
    }
    
    // MARK: - Image Download Examples
    
    func testExample_ImageDownloadSuccess() async throws {
        // EXAMPLE: How to test image downloads
        
        // Given - Create test image data
        let testImage = UIImage(systemName: "photo")!
        let imageData = testImage.pngData()!
        
        createTestScenario()
            .withCustomResponse(
                for: "test-image.jpg",
                response: MockResponse(
                    data: imageData,
                    statusCode: 200,
                    headers: ["Content-Type": "image/png"]
                )
            )
            .build()
        
        // When
        let result = try await networkManager.downloadImage(from: "https://example.com/test-image.jpg")
        
        // Then
        XCTAssertNotNil(result)
    }
    
    // MARK: - Performance Testing Examples
    
    func testExample_PerformanceTesting() throws {
        // EXAMPLE: How to do performance testing
        
        // Given
        createTestScenario()
            .withSuccessfulAppetizers()
            .build()
        
        // When & Then - Measure performance
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            
            Task {
                do {
                    _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
    
    // MARK: - Real-World Scenario Examples
    
    func testExample_LoadingStateScenario() async throws {
        // EXAMPLE: How to test loading states with delays
        
        // Given - Setup response with realistic delay
        createTestScenario()
            .withSuccessfulAppetizers(delay: 0.5)
            .build()
        
        var isRequestInProgress = false
        var requestResult: AppetizerResponse?
        
        // When - Start request and track loading state
        let requestTask = Task {
            isRequestInProgress = true
            let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
            isRequestInProgress = false
            return result
        }
        
        // Give the task a moment to start
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        // Simulate checking loading state - should be in progress
        XCTAssertTrue(isRequestInProgress, "Request should be in progress")
        XCTAssertNil(requestResult, "Result should not be available yet")
        
        
        // Wait for completion
        requestResult = try await requestTask.value
        
        // Then - verify request completed successfully
        XCTAssertFalse(isRequestInProgress, "Request should no longer be in progress")
        XCTAssertNotNil(requestResult, "Result should be available")
        XCTAssertEqual(requestResult?.request.count, 3)
        XCTAssertFalse(requestTask.isCancelled, "Task should not be cancelled")
    }
    
    func testExample_RetryMechanism() async throws {
        // EXAMPLE: How to test retry scenarios
        
        var attemptCount = 0
        let maxRetries = 3
        
        for attempt in 1...maxRetries {
            // Setup failure for first two attempts, success for third
            createTestScenario().clear()
            
            if attempt < 3 {
                createTestScenario()
                    .withFailedAppetizers(statusCode: 503) // Service unavailable
                    .build()
                
                do {
                    _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
                    XCTFail("Expected attempt \(attempt) to fail")
                } catch {
                    attemptCount += 1
                    // Continue to next retry
                }
            } else {
                createTestScenario()
                    .withSuccessfulAppetizers()
                    .build()
                
                let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
                XCTAssertEqual(result.request.count, 3)
                attemptCount += 1
                break
            }
        }
        
        XCTAssertEqual(attemptCount, 3, "Should have made 3 attempts")
    }
    
    func testExample_CachingBehavior() async throws {
        // EXAMPLE: How to test caching (if implemented)
        
        // Given - Setup successful response
        createTestScenario()
            .withSuccessfulAppetizers(delay: 0.1)
            .build()
        
        // When - Make first request (should hit network)
        let startTime1 = Date()
        let result1 = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
        let duration1 = Date().timeIntervalSince(startTime1)
        
        // Make second request (might use cache)
        let startTime2 = Date()
        let result2 = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
        
        // Then
        XCTAssertEqual(result1.request.count, result2.request.count)
        XCTAssertGreaterThanOrEqual(duration1, 0.1, "First request should take at least 0.1 seconds")
        // Note: Second request duration depends on caching implementation
    }
}
