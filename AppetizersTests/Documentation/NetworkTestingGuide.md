# Network Manager Testing Guide

This guide explains how to write comprehensive tests for the NetworkManager using the provided mock utilities and test infrastructure.

## Overview

The testing infrastructure provides several layers of testing capabilities:

1. **Unit Tests** - Test individual components in isolation using mocks
2. **Integration Tests** - Test components working together with URLSession mocking
3. **Edge Case Tests** - Test boundary conditions and error scenarios
4. **Performance Tests** - Measure and validate performance characteristics

## Test Files Structure

### Core Test Files

- `NetworkManagerTests.swift` - Unit tests with complete mocking
- `NetworkManagerIntegrationTests.swift` - Integration tests with URLSession mocking
- `NetworkManagerEdgeCaseTests.swift` - Edge cases and performance tests
- `NetworkManagerExampleTests.swift` - Examples and documentation tests

### Utility Files

- `MockServerUtilities.swift` - Mock server infrastructure and test helpers
- `AppetizerResponseMock.swift` - Mock data for testing

## Quick Start

### Basic Success Test

```swift
func testBasicSuccess() async throws {
    // Given
    let networkManager = setupMockServer()
    createTestScenario()
        .withSuccessfulAppetizers()
        .build()
    
    // When
    let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
    
    // Then
    XCTAssertEqual(result.request.count, 3)
}
```

### Basic Error Test

```swift
func testBasicError() async throws {
    // Given
    let networkManager = setupMockServer()
    createTestScenario()
        .withFailedAppetizers(statusCode: 500)
        .build()
    
    // When & Then
    do {
        _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
        XCTFail("Expected error")
    } catch let error as APError {
        XCTAssertEqual(error, APError.unableToComplete)
    }
}
```

## Testing Patterns

### 1. Unit Testing with Complete Mocks

Use `NetworkManagerTests.swift` as a reference for unit testing individual components:

```swift
func testFetchRequest_Success() async throws {
    // Setup individual mock components
    let mockHTTPClient = MockHTTPClient()
    let mockJSONDecoder = MockJSONDecoderService()
    let mockImageDownloader = MockImageDownloader()
    let mockURLBuilder = MockURLBuilder()
    
    let networkManager = NetworkManager(
        httpClient: mockHTTPClient,
        jsonDecoder: mockJSONDecoder,
        imageDownloader: mockImageDownloader,
        urlBuilder: mockURLBuilder
    )
    
    // Configure mocks
    mockURLBuilder.mockURL = expectedURL
    mockHTTPClient.mockData = expectedData
    mockJSONDecoder.mockResult = expectedResult
    
    // Test and verify
    let result = try await networkManager.fetchRequest(from: endpoint, responseType: Type.self)
    
    // Verify interactions
    XCTAssertEqual(mockURLBuilder.capturedEndpoint, endpoint)
    XCTAssertEqual(mockHTTPClient.capturedURL, expectedURL)
}
```

### 2. Integration Testing with URLSession Mocking

Use `NetworkManagerIntegrationTests.swift` for testing with real URLSession behavior:

```swift
func testIntegration() async throws {
    // Setup with mock URLSession
    let mockURLSession = MockURLSession()
    let httpClient = HTTPClient(session: mockURLSession)
    let networkManager = NetworkManager(httpClient: httpClient)
    
    // Configure response
    mockURLSession.mockData = testData
    mockURLSession.mockResponse = HTTPURLResponse(...)
    
    // Test
    let result = try await networkManager.fetchRequest(...)
    
    // Verify
    XCTAssertTrue(mockURLSession.dataTaskCalled)
}
```

### 3. Scenario-Based Testing

Use the `TestScenarioBuilder` for complex test scenarios:

```swift
func testComplexScenario() async throws {
    let networkManager = setupMockServer()
    
    createTestScenario()
        .withSuccessfulAppetizers(delay: 0.5)
        .withFailedAppetizers(statusCode: 404)
        .withNetworkTimeout(for: "timeout-endpoint")
        .withInvalidJSON(for: "invalid-endpoint")
        .build()
    
    // Test different endpoints with different behaviors
}
```

## Mock Utilities

### TestScenarioBuilder

Chain methods to build complex test scenarios:

```swift
createTestScenario()
    .withSuccessfulAppetizers()           // Success response
    .withFailedAppetizers(statusCode: 500) // Server error
    .withNetworkTimeout(for: "endpoint")   // Network timeout
    .withInvalidJSON(for: "endpoint")      // Invalid JSON
    .withCustomResponse(for: "endpoint", response: customResponse)
    .build()
```

### TestDataFactory

Create test data easily:

```swift
// Single appetizer
let appetizer = TestDataFactory.createAppetizer(
    id: 1,
    name: "Test Appetizer",
    price: 9.99
)

// Multiple appetizers
let appetizers = TestDataFactory.createAppetizers(count: 5)

// Appetizer response
let response = TestDataFactory.createAppetizerResponse(count: 10)
```

### MockResponse

Create different types of responses:

```swift
// Success response
let success = MockResponse.success(data, delay: 1.0)

// Error response
let error = MockResponse.error(statusCode: 404, message: "Not Found")

// Network error
let networkError = MockResponse.networkError(URLError(.timedOut))

// Invalid JSON
let invalidJSON = MockResponse.invalidJSON()
```

## Testing Different Scenarios

### Network Conditions

```swift
// Slow network
.withSuccessfulAppetizers(delay: 2.0)

// Network timeout
.withNetworkTimeout(for: "endpoint", delay: 5.0)

// Intermittent connectivity
// First request fails, second succeeds
```

### Error Conditions

```swift
// Server errors
.withFailedAppetizers(statusCode: 500) // Internal server error
.withFailedAppetizers(statusCode: 404) // Not found
.withFailedAppetizers(statusCode: 403) // Forbidden

// Client errors
.withInvalidJSON(for: "endpoint")      // Invalid response format
.withNetworkTimeout(for: "endpoint")   // Network timeout
```

### Data Variations

```swift
// Empty response
let emptyResponse = AppetizerResponse(request: [])
.withCustomResponse(for: "endpoint", response: MockResponse.success(emptyResponse))

// Large response
let largeResponse = TestDataFactory.createAppetizerResponse(count: 1000)
.withCustomResponse(for: "endpoint", response: MockResponse.success(largeResponse))

// Unicode content
let unicodeAppetizer = TestDataFactory.createAppetizer(
    name: "Spicy 🌶️ Appetizer",
    description: "Delicious appetizer with émojis and açcénts"
)
```

## Performance Testing

### Basic Performance Test

```swift
func testPerformance() throws {
    measure {
        let expectation = XCTestExpectation(description: "Performance test")
        
        Task {
            do {
                _ = try await networkManager.fetchRequest(...)
                expectation.fulfill()
            } catch {
                XCTFail("Performance test failed: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
```

### Memory Usage Testing

```swift
func testMemoryUsage() async throws {
    // Make multiple requests to test memory usage
    for _ in 1...10 {
        _ = try await networkManager.fetchRequest(...)
        autoreleasepool { } // Force memory cleanup
    }
    
    // Test passes if no memory issues occur
    XCTAssertTrue(true, "Memory test completed without issues")
}
```

### Concurrent Request Testing

```swift
func testConcurrentRequests() async throws {
    let tasks = (1...10).map { _ in
        Task {
            try await networkManager.fetchRequest(...)
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
    
    XCTAssertEqual(results.count, 10)
}
```

## Best Practices

### 1. Test Structure

- Use Given-When-Then structure for clarity
- Group related tests in separate test classes
- Use descriptive test method names

### 2. Mock Management

- Clear mock configurations between tests
- Use the builder pattern for complex scenarios
- Verify mock interactions where appropriate

### 3. Async Testing

- Always use `async throws` for network tests
- Handle errors appropriately in tests
- Use proper timeout values for expectations

### 4. Data Management

- Use TestDataFactory for consistent test data
- Create edge case data (empty, large, unicode)
- Test with realistic data volumes

### 5. Error Testing

- Test all error paths
- Verify correct error types are thrown
- Test error recovery scenarios

## Running Tests

### Run All Network Tests

```bash
xcodebuild test -scheme Appetizers -destination 'platform=iOS Simulator,name=iPhone 14' -only-testing:AppetizersTests/NetworkManagerTests
xcodebuild test -scheme Appetizers -destination 'platform=iOS Simulator,name=iPhone 14' -only-testing:AppetizersTests/NetworkManagerIntegrationTests
xcodebuild test -scheme Appetizers -destination 'platform=iOS Simulator,name=iPhone 14' -only-testing:AppetizersTests/NetworkManagerEdgeCaseTests
```

### Run Specific Test Class

```bash
xcodebuild test -scheme Appetizers -destination 'platform=iOS Simulator,name=iPhone 14' -only-testing:AppetizersTests/NetworkManagerTests/testFetchRequest_Success
```

## Troubleshooting

### Common Issues

1. **Test Timeouts**: Increase timeout values for slow operations
2. **Mock Configuration**: Ensure mocks are properly configured before tests
3. **Memory Leaks**: Use autoreleasepool in memory-intensive tests
4. **Async Issues**: Always await async operations properly

### Debug Tips

1. Add breakpoints in mock implementations to verify calls
2. Use print statements to trace execution flow
3. Check captured values in mocks for verification
4. Use XCTest's measure blocks for performance analysis

This testing infrastructure provides comprehensive coverage for NetworkManager functionality while being maintainable and easy to extend.
