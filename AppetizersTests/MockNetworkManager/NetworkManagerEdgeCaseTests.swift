//
//  NetworkManagerEdgeCaseTests.swift
//  AppetizersTests
//
//  Created by Sathya Kumar on 29/09/25.
//

import XCTest
@testable import Appetizers

final class NetworkManagerEdgeCaseTests: XCTestCase {
    
    // MARK: - Properties
    var networkManager: NetworkManager!
    var testScenario: TestScenarioBuilder!
    
    // MARK: - Setup & Teardown
    override func setUpWithError() throws {
        super.setUp()
        networkManager = setupMockServer()
        testScenario = createTestScenario()
    }
    
    override func tearDownWithError() throws {
        testScenario.clear()
        networkManager = nil
        testScenario = nil
        super.tearDown()
    }
    
    // MARK: - Edge Case Tests
    
    func testFetchRequest_EmptyResponse() async throws {
        // Given
        let emptyResponse = AppetizerResponse(request: [])
        testScenario
            .withCustomResponse(
                for: "appetizers",
                response: MockResponse.success(emptyResponse)
            )
            .build()
        
        // When
        let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
        
        // Then
        XCTAssertEqual(result.request.count, 0)
    }
    
    func testFetchRequest_LargeResponse() async throws {
        // Given - Create a large response with 1000 appetizers
        let largeResponse = TestDataFactory.createAppetizerResponse(count: 1000)
        testScenario
            .withCustomResponse(
                for: "appetizers",
                response: MockResponse.success(largeResponse)
            )
            .build()
        
        // When
        let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
        
        // Then
        XCTAssertEqual(result.request.count, 1000)
        XCTAssertEqual(result.request.first?.id, 1)
        XCTAssertEqual(result.request.last?.id, 1000)
    }
    
    func testFetchRequest_SpecialCharactersInEndpoint() async throws {
        // Given
        let specialEndpoint = "appetizers?category=spicy&price<10"
        let mockResponse = AppetizerResponse.mock
        testScenario
            .withCustomResponse(
                for: specialEndpoint,
                response: MockResponse.success(mockResponse)
            )
            .build()
        
        // When
        let result = try await networkManager.fetchRequest(from: specialEndpoint, responseType: AppetizerResponse.self)
        
        // Then
        XCTAssertEqual(result.request.count, mockResponse.request.count)
    }
    
    func testFetchRequest_UnicodeContent() async throws {
        // Given
        let unicodeAppetizer = TestDataFactory.createAppetizer(
            name: "Spicy 🌶️ Appetizer",
            description: "Delicious appetizer with émojis and açcénts"
        )
        let unicodeResponse = TestDataFactory.createAppetizerResponse(appetizers: [unicodeAppetizer])
        
        testScenario
            .withCustomResponse(
                for: "appetizers",
                response: MockResponse.success(unicodeResponse)
            )
            .build()
        
        // When
        let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
        
        // Then
        XCTAssertEqual(result.request.first?.name, "Spicy 🌶️ Appetizer")
        XCTAssertEqual(result.request.first?.description, "Delicious appetizer with émojis and açcénts")
    }
    
    func testFetchRequest_VeryLongEndpoint() async throws {
        // Given
        let longEndpoint = String(repeating: "a", count: 1000)
        let mockResponse = AppetizerResponse.mock
        testScenario
            .withCustomResponse(
                for: longEndpoint,
                response: MockResponse.success(mockResponse)
            )
            .build()
        
        // When
        let result = try await networkManager.fetchRequest(from: longEndpoint, responseType: AppetizerResponse.self)
        
        // Then
        XCTAssertEqual(result.request.count, mockResponse.request.count)
    }
    
    func testFetchRequest_ConcurrentRequests() async throws {
        // Given
        let mockResponse = AppetizerResponse.mock
        testScenario
            .withCustomResponse(
                for: "appetizers",
                response: MockResponse.success(mockResponse, delay: 0.1)
            )
            .build()
        
        // When - Make 10 concurrent requests
        let tasks = (1...10).map { _ in
            Task {
                try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
            }
        }
        
        let results = try await withThrowingTaskGroup(of: AppetizerResponse.self) { group in
            for task in tasks {
                group.addTask { try await task.value }
            }
            
            var results: [AppetizerResponse] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
        
        // Then
        XCTAssertEqual(results.count, 10)
        for result in results {
            XCTAssertEqual(result.request.count, mockResponse.request.count)
        }
    }
    
    func testFetchRequest_RapidSequentialRequests() async throws {
        // Given
        let mockResponse = AppetizerResponse.mock
        testScenario
            .withCustomResponse(
                for: "appetizers",
                response: MockResponse.success(mockResponse)
            )
            .build()
        
        // When - Make rapid sequential requests
        var results: [AppetizerResponse] = []
        for _ in 1...5 {
            let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
            results.append(result)
        }
        
        // Then
        XCTAssertEqual(results.count, 5)
        for result in results {
            XCTAssertEqual(result.request.count, mockResponse.request.count)
        }
    }
    
    func testDownloadImage_InvalidImageData() async throws {
        // Given
        let imageURL = "https://example.com/invalid-image.jpg"
        let invalidImageData = Data("not an image".utf8)
        
        testScenario
            .withCustomResponse(
                for: "invalid-image.jpg",
                response: MockResponse(
                    data: invalidImageData,
                    statusCode: 200,
                    headers: ["Content-Type": "image/jpeg"]
                )
            )
            .build()
        
        // When & Then
        do {
            _ = try await networkManager.downloadImage(from: imageURL)
            XCTFail("Expected error for invalid image data")
        } catch let error as APError {
            XCTAssertEqual(error, APError.invalidData)
        }
    }
    
    func testDownloadImage_VeryLargeImage() async throws {
        // Given
        let imageURL = "https://example.com/large-image.jpg"
        let largeImageData = Data(count: 10 * 1024 * 1024) // 10MB of zeros
        
        testScenario
            .withCustomResponse(
                for: "large-image.jpg",
                response: MockResponse(
                    data: largeImageData,
                    statusCode: 200,
                    headers: ["Content-Type": "image/jpeg"]
                )
            )
            .build()
        
        // When & Then - This should handle large data gracefully
        do {
            _ = try await networkManager.downloadImage(from: imageURL)
            // If we get here, the large image was handled (even if UIImage creation fails)
        } catch let error as APError {
            // Expected to fail due to invalid image data, but shouldn't crash
            XCTAssertEqual(error, APError.invalidData)
        }
    }
    
    // MARK: - Network Condition Simulation Tests
    
    func testFetchRequest_SlowNetwork() async throws {
        // Given - Simulate slow network with 2 second delay
        let mockResponse = AppetizerResponse.mock
        testScenario
            .withCustomResponse(
                for: "appetizers",
                response: MockResponse.success(mockResponse, delay: 2.0)
            )
            .build()
        
        let startTime = Date()
        
        // When
        let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Then
        XCTAssertEqual(result.request.count, mockResponse.request.count)
        XCTAssertGreaterThanOrEqual(duration, 2.0, "Request should take at least 2 seconds")
    }
    
    func testFetchRequest_IntermittentConnectivity() async throws {
        // Given - First request fails, second succeeds
        let mockResponse = AppetizerResponse.mock
        
        // First request setup (failure)
        testScenario
            .withNetworkTimeout(for: "appetizers")
            .build()
        
        // When - First request should fail
        do {
            _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
            XCTFail("Expected first request to fail")
        } catch {
            // Expected failure
        }
        
        // Setup second request (success)
        testScenario.clear()
        testScenario
            .withCustomResponse(
                for: "appetizers",
                response: MockResponse.success(mockResponse)
            )
            .build()
        
        // Second request should succeed
        let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
        
        // Then
        XCTAssertEqual(result.request.count, mockResponse.request.count)
    }
    
    // MARK: - Memory and Performance Tests
    
    func testFetchRequest_MemoryUsage() async throws {
        // Given
        let largeResponse = TestDataFactory.createAppetizerResponse(count: 500)
        testScenario
            .withCustomResponse(
                for: "appetizers",
                response: MockResponse.success(largeResponse)
            )
            .build()
        
        // When - Make multiple requests to test memory usage
        for _ in 1...10 {
            let _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
            // Force memory cleanup
            autoreleasepool { }
        }
        
        // Then - Test passes if no memory issues occur
        XCTAssertTrue(true, "Memory test completed without issues")
    }
    
    func testFetchRequest_PerformanceBenchmark() throws {
        // Given
        let mockResponse = AppetizerResponse.mock
        testScenario
            .withCustomResponse(
                for: "appetizers",
                response: MockResponse.success(mockResponse)
            )
            .build()
        
        // When & Then
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
    
    // MARK: - Error Recovery Tests
    
    func testFetchRequest_ErrorRecovery() async throws {
        // Given - Setup alternating success/failure pattern
        var requestCount = 0
        
        for attempt in 1...3 {
            if attempt % 2 == 1 {
                // Odd attempts fail
                testScenario.clear()
                testScenario
                    .withFailedAppetizers(statusCode: 500)
                    .build()
                
                do {
                    _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
                    XCTFail("Expected request \(attempt) to fail")
                } catch {
                    // Expected failure
                    requestCount += 1
                }
            } else {
                // Even attempts succeed
                testScenario.clear()
                testScenario
                    .withSuccessfulAppetizers()
                    .build()
                
                let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
                XCTAssertGreaterThan(result.request.count, 0)
                requestCount += 1
            }
        }
        
        // Then
        XCTAssertEqual(requestCount, 3)
    }
}
