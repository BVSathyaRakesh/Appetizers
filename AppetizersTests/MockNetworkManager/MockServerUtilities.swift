//
//  MockServerUtilities.swift
//  AppetizersTests
//
//  Created by Sathya Kumar on 29/09/25.
//

import Foundation
import XCTest
@testable import Appetizers

// MARK: - Mock Server Manager

/// Utility class for managing mock server responses in tests
final class MockServerManager {
    static let shared = MockServerManager()
    
    private var mockResponses: [String: MockResponse] = [:]
    private var defaultDelay: TimeInterval = 0.1
    
    private init() {}
    
    /// Configure a mock response for a specific endpoint
    func configureMockResponse(for endpoint: String, response: MockResponse) {
        mockResponses[endpoint] = response
    }
    
    /// Get configured mock response for endpoint
    func getMockResponse(for endpoint: String) -> MockResponse? {
        return mockResponses[endpoint]
    }
    
    /// Clear all configured mock responses
    func clearAllMockResponses() {
        mockResponses.removeAll()
    }
    
    /// Set default delay for all mock responses
    func setDefaultDelay(_ delay: TimeInterval) {
        defaultDelay = delay
    }
    
    /// Simulate network delay
    func simulateNetworkDelay() async {
        try? await Task.sleep(nanoseconds: UInt64(defaultDelay * 1_000_000_000))
    }
}

// MARK: - Mock Response Model

struct MockResponse {
    let data: Data?
    let statusCode: Int
    let headers: [String: String]?
    let error: Error?
    let delay: TimeInterval?
    
    init(
        data: Data? = nil,
        statusCode: Int = 200,
        headers: [String: String]? = nil,
        error: Error? = nil,
        delay: TimeInterval? = nil
    ) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
        self.error = error
        self.delay = delay
    }
    
    // MARK: - Convenience Initializers
    
    /// Success response with JSON data
    static func success<T: Encodable>(_ object: T, delay: TimeInterval? = nil) -> MockResponse {
        let data = try? JSONEncoder().encode(object)
        return MockResponse(
            data: data,
            statusCode: 200,
            headers: ["Content-Type": "application/json"],
            delay: delay
        )
    }
    
    /// Error response with specific status code
    static func error(statusCode: Int, message: String? = nil, delay: TimeInterval? = nil) -> MockResponse {
        let data = message?.data(using: .utf8)
        return MockResponse(
            data: data,
            statusCode: statusCode,
            delay: delay
        )
    }
    
    /// Network error response
    static func networkError(_ error: Error, delay: TimeInterval? = nil) -> MockResponse {
        return MockResponse(error: error, delay: delay)
    }
    
    /// Invalid JSON response
    static func invalidJSON(delay: TimeInterval? = nil) -> MockResponse {
        let invalidJSONData = "{ invalid json }".data(using: .utf8)
        return MockResponse(
            data: invalidJSONData,
            statusCode: 200,
            headers: ["Content-Type": "application/json"],
            delay: delay
        )
    }
}

// MARK: - Mock URLSession Implementation

class MockServerURLSession: URLSessionProtocol {
    private let serverManager = MockServerManager.shared
    
    // Captured values for verification
    var capturedRequest: URLRequest?
    var dataTaskCalled = false
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataTaskCalled = true
        capturedRequest = request
        
        guard let url = request.url else {
            throw APError.invalidURL
        }
        
        // Extract endpoint from URL
        let endpoint = extractEndpoint(from: url)
        
        // Get mock response configuration
        guard let mockResponse = serverManager.getMockResponse(for: endpoint) else {
            throw APError.unableToComplete
        }
        
        // Simulate network delay if specified
        if let delay = mockResponse.delay {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        } else {
            await serverManager.simulateNetworkDelay()
        }
        
        // Throw error if configured
        if let error = mockResponse.error {
            throw error
        }
        
        // Create HTTP response
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: mockResponse.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: mockResponse.headers
        )!
        
        let data = mockResponse.data ?? Data()
        return (data, httpResponse)
    }
    
    private func extractEndpoint(from url: URL) -> String {
        // Extract the endpoint part from the full URL
        let baseURL = "http://localhost:3000/swiftui-fundamentals/"
        let fullPath = url.absoluteString
        
        if fullPath.hasPrefix(baseURL) {
            let endpoint = String(fullPath.dropFirst(baseURL.count))
            // URL decode the endpoint to match the original key used in test setup
            return endpoint.removingPercentEncoding ?? endpoint
        }
        
        return url.lastPathComponent
    }
}

// MARK: - Test Scenario Builder

/// Builder pattern for creating complex test scenarios
class TestScenarioBuilder {
    private var scenarios: [String: MockResponse] = [:]
    
    /// Add a successful appetizers response
    @discardableResult
    func withSuccessfulAppetizers(delay: TimeInterval? = nil) -> TestScenarioBuilder {
        let response = MockResponse.success(AppetizerResponse.mock, delay: delay)
        scenarios["appetizers"] = response
        return self
    }
    
    /// Add a failed appetizers response
    @discardableResult
    func withFailedAppetizers(statusCode: Int = 500, delay: TimeInterval? = nil) -> TestScenarioBuilder {
        let response = MockResponse.error(statusCode: statusCode, message: "Server Error", delay: delay)
        scenarios["appetizers"] = response
        return self
    }
    
    /// Add a network timeout scenario
    @discardableResult
    func withNetworkTimeout(for endpoint: String, delay: TimeInterval = 5.0) -> TestScenarioBuilder {
        let response = MockResponse.networkError(URLError(.timedOut), delay: delay)
        scenarios[endpoint] = response
        return self
    }
    
    /// Add an invalid JSON response
    @discardableResult
    func withInvalidJSON(for endpoint: String, delay: TimeInterval? = nil) -> TestScenarioBuilder {
        let response = MockResponse.invalidJSON(delay: delay)
        scenarios[endpoint] = response
        return self
    }
    
    /// Add a custom response
    @discardableResult
    func withCustomResponse(for endpoint: String, response: MockResponse) -> TestScenarioBuilder {
        scenarios[endpoint] = response
        return self
    }
    
    /// Build and configure the scenario
    func build() {
        for (endpoint, response) in scenarios {
            MockServerManager.shared.configureMockResponse(for: endpoint, response: response)
        }
    }
    
    /// Clear the current scenario
    func clear() {
        scenarios.removeAll()
        MockServerManager.shared.clearAllMockResponses()
    }
}

// MARK: - Test Data Factory

struct TestDataFactory {
    
    /// Create a single appetizer for testing
    static func createAppetizer(
        id: Int = 1,
        name: String = "Test Appetizer",
        description: String = "Test Description",
        price: Double = 9.99,
        imageURL: String = "https://example.com/test.jpg",
        calories: Int = 200,
        protein: Int = 10,
        carbs: Int = 20
    ) -> Appetizer {
        return Appetizer(
            id: id,
            name: name,
            description: description,
            price: price,
            imageURL: imageURL,
            calories: calories,
            protein: protein,
            carbs: carbs
        )
    }
    
    /// Create multiple appetizers for testing
    static func createAppetizers(count: Int) -> [Appetizer] {
        return (1...count).map { index in
            createAppetizer(
                id: index,
                name: "Test Appetizer \(index)",
                description: "Test Description \(index)",
                price: Double(index) * 2.99
            )
        }
    }
    
    /// Create an appetizer response with specified appetizers
    static func createAppetizerResponse(appetizers: [Appetizer]) -> AppetizerResponse {
        return AppetizerResponse(request: appetizers)
    }
    
    /// Create an appetizer response with specified count
    static func createAppetizerResponse(count: Int) -> AppetizerResponse {
        let appetizers = createAppetizers(count: count)
        return createAppetizerResponse(appetizers: appetizers)
    }
}

// MARK: - Network Test Helpers

/// Helper functions for network testing
struct NetworkTestHelpers {
    
    /// Setup mock server for network tests
    static func setupMockServer() -> NetworkManager {
        let mockSession = MockServerURLSession()
        let httpClient = HTTPClient(session: mockSession)
        
        // Create ImageDownloader with the same mock HTTPClient
        let imageDownloader = ImageDownloader(httpClient: httpClient)
        
        return NetworkManager(
            httpClient: httpClient,
            jsonDecoder: JSONDecoderService(),
            imageDownloader: imageDownloader,
            urlBuilder: URLBuilder()
        )
    }
    
    /// Create a test scenario builder
    static func createTestScenario() -> TestScenarioBuilder {
        return TestScenarioBuilder()
    }
    
    /// Wait for async operation with timeout
    static func waitForAsync<T>(
        timeout: TimeInterval = 1.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw TimeoutError()
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

// MARK: - XCTestCase Extension

extension XCTestCase {
    
    /// Setup mock server for network tests
    func setupMockServer() -> NetworkManager {
        return NetworkTestHelpers.setupMockServer()
    }
    
    /// Create a test scenario builder
    func createTestScenario() -> TestScenarioBuilder {
        return NetworkTestHelpers.createTestScenario()
    }
}

// MARK: - Custom Errors

struct TimeoutError: Error {
    let message = "Operation timed out"
}
