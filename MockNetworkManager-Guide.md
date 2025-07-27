# MockNetworkManager & Dependency Injection Guide

## 🎯 Table of Contents
1. [What is MockNetworkManager?](#what-is-mocknetworkmanager)
2. [The Problem Without Mocking](#the-problem-without-mocking)
3. [How MockNetworkManager Works](#how-mocknetworkmanager-works)
4. [Code Examples from Your Project](#code-examples-from-your-project)
5. [Benefits of Mocking](#benefits-of-mocking)
6. [Testing Scenarios](#testing-scenarios)
7. [Best Practices](#best-practices)
8. [Key Takeaways](#key-takeaways)

---

## What is MockNetworkManager?

**MockNetworkManager** is a **fake implementation** of your real NetworkManager that:
- ✅ **Pretends to be** the real NetworkManager
- ✅ **Doesn't make real network calls**
- ✅ **Returns predefined responses** you control
- ✅ **Tracks what was called** for verification

### The Core Concept: Substitution
```swift
// Both implement the same protocol
protocol NetworkManagerProtocol {
    func fetchAppetizers() async throws -> [Appetizer]
}

// Real implementation - makes HTTP calls
class NetworkManager: NetworkManagerProtocol {
    func fetchAppetizers() async throws -> [Appetizer] {
        // Makes real HTTP request to localhost:3000
    }
}

// Mock implementation - returns fake data
class MockNetworkManager: NetworkManagerProtocol {
    func fetchAppetizers() async throws -> [Appetizer] {
        // Returns fake data YOU control!
    }
}
```

---

## The Problem Without Mocking

### ❌ Testing with Real NetworkManager:
```swift
func test_GetAppetizers() {
    let viewModel = AppetizerListViewModel() // Uses real NetworkManager.shared
    
    viewModel.getAppetizers() // 💥 Makes REAL network call!
    
    // Problems:
    // ❌ Requires internet connection
    // ❌ Slow (2-5 seconds per test)
    // ❌ Unpredictable (server might be down)
    // ❌ Can't test error scenarios easily
    // ❌ Tests fail randomly due to network issues
    // ❌ Can't test offline scenarios
}
```

### Real-World Pain Points:
- **Slow Test Suite**: 100 tests × 3 seconds = 5 minutes just waiting
- **Flaky Tests**: "Test failed because WiFi was slow"
- **Limited Error Testing**: Hard to simulate server errors
- **CI/CD Issues**: Tests fail in build pipeline due to network
- **Development Friction**: Can't test without internet

---

## How MockNetworkManager Works

### 1. **Protocol-Based Substitution**
```swift
class AppetizerListViewModel: ObservableObject {
    private let networkManager: NetworkManagerProtocol
    
    // Dependency Injection - can accept real OR mock
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func getAppetizers() {
        // Calls whatever implementation was injected
        appetizers = try await networkManager.fetchAppetizers()
    }
}
```

### 2. **Controllable Responses**
```swift
class MockNetworkManager: NetworkManagerProtocol {
    // 🎛️ Controls what the mock returns
    var shouldReturnError = false
    var errorToReturn: APError = .invalidData
    var appetizersToReturn: [Appetizer] = []
    
    func fetchAppetizers() async throws -> [Appetizer] {
        if shouldReturnError {
            throw errorToReturn  // 🚨 Simulate error
        }
        return appetizersToReturn    // ✅ Return fake data
    }
    
    // Helper methods for easy configuration
    func setupSuccessResponse(with appetizers: [Appetizer]) {
        shouldReturnError = false
        appetizersToReturn = appetizers
    }
    
    func setupErrorResponse(error: APError) {
        shouldReturnError = true
        errorToReturn = error
    }
}
```

### 3. **Call Tracking & Verification**
```swift
class MockNetworkManager: NetworkManagerProtocol {
    // 📊 Tracks what happened during tests
    var fetchAppetizersCalled = false
    var fetchAppetizersCallCount = 0
    
    func fetchAppetizers() async throws -> [Appetizer] {
        fetchAppetizersCalled = true     // 📝 "This method was called"
        fetchAppetizersCallCount += 1    // 📈 "Called X times"
        
        // ... return data
    }
}
```

---

## Code Examples from Your Project

### Example 1: Testing Success Scenario
```swift
func test_GetAppetizers_WithSuccessfulResponse_ShouldUpdateAppetizers() async {
    // Given - Setup mock to return fake data
    let testAppetizers = TestDataFactory.createTestAppetizers()
    mockNetworkManager.setupSuccessResponse(with: testAppetizers)
    
    // When - Call the method
    viewModel.getAppetizers()
    try? await Task.sleep(nanoseconds: 100_000_000)
    
    // Then - Verify results
    XCTAssertEqual(viewModel.appetizers, testAppetizers) // Got the fake data!
    XCTAssertTrue(mockNetworkManager.fetchAppetizersCalled) // Method was called!
}
```

**What happened:**
1. 🎛️ Mock configured to return fake appetizers
2. 📞 ViewModel calls `networkManager.fetchAppetizers()`
3. 🎭 Mock returns the fake data (no network call!)
4. ✅ Test verifies ViewModel updated correctly

### Example 2: Testing Error Scenario
```swift
func test_GetAppetizers_WithInvalidURL_ShouldShowAlert() async {
    // Given - Setup mock to throw error
    mockNetworkManager.setupErrorResponse(error: .invalidURL)
    
    // When - Call the method
    viewModel.getAppetizers()
    try? await Task.sleep(nanoseconds: 100_000_000)
    
    // Then - Verify error handling
    XCTAssertNotNil(viewModel.alertItem) // Alert was shown!
    XCTAssertTrue(viewModel.appetizers.isEmpty) // No data loaded
    XCTAssertFalse(viewModel.isLoading) // Loading stopped
}
```

**What happened:**
1. 🚨 Mock configured to throw `.invalidURL` error
2. 📞 ViewModel calls `networkManager.fetchAppetizers()`
3. 💥 Mock throws the error (simulated network failure!)
4. ✅ Test verifies ViewModel handled error correctly

### Example 3: Testing Call Tracking
```swift
func test_GetAppetizers_CalledMultipleTimes_ShouldTrackCallCount() async {
    // Given
    mockNetworkManager.setupSuccessResponse(with: [])
    
    // When - Call multiple times
    viewModel.getAppetizers()
    try? await Task.sleep(nanoseconds: 50_000_000)
    
    viewModel.getAppetizers()
    try? await Task.sleep(nanoseconds: 50_000_000)
    
    // Then - Verify tracking
    XCTAssertEqual(mockNetworkManager.fetchAppetizersCallCount, 2)
    XCTAssertTrue(mockNetworkManager.fetchAppetizersCalled)
}
```

---

## Benefits of Mocking

### 🚀 Speed
| Approach | Time per Test | 100 Tests Total |
|----------|---------------|-----------------|
| Real NetworkManager | 2-5 seconds | 3-8 minutes |
| MockNetworkManager | 0.001 seconds | 0.1 seconds |

### 🎯 Reliability
```swift
// Real NetworkManager Results:
// ❌ "Test failed: Network timeout"
// ❌ "Test failed: Server returned 500"
// ❌ "Test failed: No internet connection"

// MockNetworkManager Results:
// ✅ Always returns exactly what you configure
// ✅ Deterministic and predictable
// ✅ No external dependencies
```

### 🎭 Error Simulation
```swift
// Easy to test ANY error scenario:
mockNetworkManager.setupErrorResponse(error: .invalidURL)
mockNetworkManager.setupErrorResponse(error: .invalidData)
mockNetworkManager.setupErrorResponse(error: .unableToComplete)
mockNetworkManager.setupErrorResponse(error: .invalidResponse)

// Real NetworkManager: Hard to simulate these errors on demand
```

### 📊 Behavior Verification
```swift
// Can verify exact interactions:
XCTAssertTrue(mockNetworkManager.fetchAppetizersCalled)
XCTAssertEqual(mockNetworkManager.fetchAppetizersCallCount, 1)

// Real NetworkManager: Can't easily verify what calls were made
```

---

## Testing Scenarios

### 1. **Success Scenarios**
```swift
// Test with empty list
mockNetworkManager.setupSuccessResponse(with: [])

// Test with single item
mockNetworkManager.setupSuccessResponse(with: [TestDataFactory.sampleAppetizer])

// Test with multiple items
mockNetworkManager.setupSuccessResponse(with: TestDataFactory.sampleAppetizers)
```

### 2. **Error Scenarios**
```swift
// Test all possible errors
mockNetworkManager.setupErrorResponse(error: .invalidURL)
mockNetworkManager.setupErrorResponse(error: .invalidResponse)
mockNetworkManager.setupErrorResponse(error: .invalidData)
mockNetworkManager.setupErrorResponse(error: .unableToComplete)
```

### 3. **Loading States**
```swift
func test_LoadingStates() async {
    // Before
    XCTAssertFalse(viewModel.isLoading)
    
    // During
    viewModel.getAppetizers()
    XCTAssertTrue(viewModel.isLoading)
    
    // After
    try? await Task.sleep(nanoseconds: 100_000_000)
    XCTAssertFalse(viewModel.isLoading)
}
```

### 4. **Edge Cases**
```swift
// Test with malformed data
let malformedAppetizer = Appetizer(id: -1, name: "", ...)
mockNetworkManager.setupSuccessResponse(with: [malformedAppetizer])

// Test with very large dataset
let manyAppetizers = (1...1000).map { TestDataFactory.createTestAppetizer(id: $0) }
mockNetworkManager.setupSuccessResponse(with: manyAppetizers)
```

---

## Best Practices

### 1. **Setup and Teardown**
```swift
class AppetizerListViewModelTests: XCTestCase {
    var viewModel: AppetizerListViewModel!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUpWithError() throws {
        mockNetworkManager = MockNetworkManager()
        viewModel = AppetizerListViewModel(networkManager: mockNetworkManager)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockNetworkManager = nil
    }
}
```

### 2. **Test Data Factory**
```swift
struct TestDataFactory {
    static func createTestAppetizer(id: Int = 1) -> Appetizer {
        return Appetizer(
            id: id,
            name: "Test Appetizer \(id)",
            description: "Test description",
            price: 9.99,
            imageURL: "https://test.com/image.jpg",
            calories: 100,
            protein: 10,
            carbs: 15
        )
    }
    
    static let sampleAppetizer = createTestAppetizer()
    static let sampleAppetizers = (1...3).map { createTestAppetizer(id: $0) }
}
```

### 3. **Clear Test Names**
```swift
// ✅ Good - Clear intention
func test_GetAppetizers_WithInvalidURL_ShouldShowAlert()
func test_GetAppetizers_WithSuccessfulResponse_ShouldUpdateAppetizers()

// ❌ Bad - Unclear intention
func test_GetAppetizers()
func test_Error()
```

### 4. **AAA Pattern (Arrange-Act-Assert)**
```swift
func test_Example() async {
    // Arrange - Setup test conditions
    mockNetworkManager.setupErrorResponse(error: .invalidURL)
    
    // Act - Execute the method under test
    viewModel.getAppetizers()
    try? await Task.sleep(nanoseconds: 100_000_000)
    
    // Assert - Verify the results
    XCTAssertNotNil(viewModel.alertItem)
    XCTAssertTrue(viewModel.appetizers.isEmpty)
}
```

---

## Key Takeaways

### 🎯 **Core Concepts**
1. **Dependency Injection** enables testability
2. **Protocol abstraction** allows substitution
3. **Mocking** isolates units under test
4. **Test doubles** provide controlled behavior

### 🏗️ **Architecture Benefits**
- **Separation of Concerns**: Business logic vs. Network logic
- **Single Responsibility**: Each class has one job
- **Dependency Inversion**: Depend on abstractions, not concretions
- **Open/Closed Principle**: Open for extension, closed for modification

### 🧪 **Testing Benefits**
- **Fast**: No network latency
- **Reliable**: No external dependencies
- **Comprehensive**: Test all scenarios
- **Isolated**: Test one thing at a time

### 🚀 **Professional Standards**
This pattern is used in:
- **iOS Apps**: Spotify, Instagram, Uber, etc.
- **Backend Services**: Microservices architecture
- **Web Applications**: React, Angular, Vue
- **Enterprise Software**: Banking, Healthcare, etc.

---

## Production vs Testing

### In Production:
```swift
// Uses real NetworkManager
let viewModel = AppetizerListViewModel()
// → Makes real HTTP calls
// → Gets real data from server
// → Handles real network conditions
```

### In Tests:
```swift
// Uses mock NetworkManager
let mockNetworkManager = MockNetworkManager()
let viewModel = AppetizerListViewModel(networkManager: mockNetworkManager)
// → No HTTP calls made
// → Returns controlled fake data
// → Simulates any scenario you want
```

**The ViewModel doesn't know the difference!** It just calls `networkManager.fetchAppetizers()` - whether it's real or fake doesn't matter to the ViewModel.

---

## Final Thoughts

**MockNetworkManager** is not just a testing tool - it's a **design pattern** that makes your code:
- **More testable**
- **More maintainable** 
- **More flexible**
- **More professional**

By implementing dependency injection and mocking, you've elevated your code to **production-grade quality** used in major iOS applications! 🏆

---

*This guide is based on the Appetizers project implementation of MVVM architecture with dependency injection and comprehensive unit testing.* 