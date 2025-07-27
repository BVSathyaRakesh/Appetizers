# Complete SwiftUI Testing Guide for Appetizers App

## Table of Contents
1. [Testing Fundamentals](#testing-fundamentals)
2. [Test Types](#test-types)
3. [Setting Up Testing in Xcode](#setting-up-testing-in-xcode)
4. [Unit Testing](#unit-testing)
5. [Integration Testing](#integration-testing)
6. [UI Testing](#ui-testing)
7. [Test-Driven Development (TDD)](#test-driven-development-tdd)
8. [Best Practices](#best-practices)
9. [Advanced Testing Techniques](#advanced-testing-techniques)
10. [Running and Organizing Tests](#running-and-organizing-tests)

## Testing Fundamentals

### What is Testing?
Testing is the process of verifying that your code works as expected. It helps you:
- Catch bugs early
- Ensure code quality
- Enable safe refactoring
- Document expected behavior
- Build confidence in your code

### The Testing Pyramid
```
    /\
   /UI\      <- Few, expensive, slow
  /____\
 /Integration\ <- Some, moderate cost
/_____________\
/  Unit Tests  \ <- Many, cheap, fast
/_______________\
```

## Test Types

### 1. Unit Tests
- **What**: Test individual components in isolation
- **When**: For models, utilities, business logic
- **Example**: Testing `Appetizer` model, `String.isValidEmail`

### 2. Integration Tests  
- **What**: Test how components work together
- **When**: For ViewModels with dependencies
- **Example**: Testing `AppetizerListViewModel` with `NetworkManager`

### 3. UI Tests
- **What**: Test user interactions and flows
- **When**: For critical user journeys
- **Example**: Testing complete order flow

## Setting Up Testing in Xcode

### Step 1: Add Test Targets

1. **Unit Testing Bundle**:
   - File → New → Target
   - Choose "Unit Testing Bundle"
   - Name: `AppetizersTests`
   - Target to be tested: `Appetizers`

2. **UI Testing Bundle**:
   - File → New → Target  
   - Choose "UI Testing Bundle"
   - Name: `AppetizersUITests`

### Step 2: Configure Test Targets

In your test target's Build Settings:
- Set `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES` to `YES`
- Ensure proper iOS deployment target

## Unit Testing

### Testing Models

```swift
// Test structure: Given-When-Then
func test_AppetizerInitialization_WithValidData_ShouldCreateAppetizer() {
    // Given - Setup test data
    let appetizer = Appetizer(
        id: 1,
        name: "Buffalo Chicken Bites",
        description: "Spicy buffalo chicken",
        price: 8.99,
        imageURL: "https://example.com/image.jpg",
        calories: 350,
        protein: 25,
        carbs: 15
    )
    
    // When - Action being tested (implicit here)
    
    // Then - Verify results
    XCTAssertEqual(appetizer.id, 1)
    XCTAssertEqual(appetizer.name, "Buffalo Chicken Bites")
    XCTAssertEqual(appetizer.price, 8.99, accuracy: 0.01)
}
```

### Testing Business Logic

```swift
func test_TotalPrice_WithMultipleItems_ShouldReturnSum() {
    // Given
    let order = Order()
    order.add(appetizer1) // 8.99
    order.add(appetizer2) // 6.99
    
    // When
    let total = order.totalPrice
    
    // Then
    XCTAssertEqual(total, 15.98, accuracy: 0.01)
}
```

### Testing Validation Logic

```swift
func test_EmailValidation_WithValidEmail_ShouldReturnTrue() {
    // Given
    let validEmail = "user@example.com"
    
    // When
    let isValid = validEmail.isValidEmail
    
    // Then
    XCTAssertTrue(isValid)
}
```

## Integration Testing

### Testing ViewModels with Mocks

```swift
@MainActor
final class AppetizerListViewModelTests: XCTestCase {
    var viewModel: AppetizerListViewModel!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUpWithError() throws {
        mockNetworkManager = MockNetworkManager()
        viewModel = AppetizerListViewModel(networkManager: mockNetworkManager)
    }
    
    func test_GetAppetizers_WithSuccessfulResponse_ShouldUpdateAppetizers() async {
        // Given
        let testAppetizers = [/* test data */]
        mockNetworkManager.setupSuccessResponse(with: testAppetizers)
        
        // When
        viewModel.getAppetizers()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.appetizers.count, testAppetizers.count)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.alertItem)
    }
}
```

### Creating Mock Objects

```swift
protocol NetworkManagerProtocol {
    func fetchAppetizers() async throws -> [Appetizer]
}

class MockNetworkManager: NetworkManagerProtocol {
    var shouldReturnError = false
    var appetizersToReturn: [Appetizer] = []
    
    func fetchAppetizers() async throws -> [Appetizer] {
        if shouldReturnError {
            throw APError.invalidData
        }
        return appetizersToReturn
    }
    
    func setupSuccessResponse(with appetizers: [Appetizer]) {
        shouldReturnError = false
        appetizersToReturn = appetizers
    }
}
```

## UI Testing

### Testing Navigation

```swift
func test_TabNavigation_ShouldSwitchBetweenTabs() throws {
    let app = XCUIApplication()
    
    // Given
    let appetizerTab = app.tabBars.buttons["Appetizers"]
    let accountTab = app.tabBars.buttons["Account"]
    
    // When
    accountTab.tap()
    
    // Then
    XCTAssertTrue(accountTab.isSelected)
}
```

### Testing Form Input

```swift
func test_AccountForm_WithValidInput_ShouldSaveSuccessfully() throws {
    let app = XCUIApplication()
    
    // Navigate to account tab
    app.tabBars.buttons["Account"].tap()
    
    // Fill form
    app.textFields["First Name"].tap()
    app.textFields["First Name"].typeText("John")
    
    app.textFields["Email"].tap()
    app.textFields["Email"].typeText("john@example.com")
    
    app.buttons["Save Changes"].tap()
    
    // Verify success
    XCTAssertTrue(app.alerts["Profile Saved"].exists)
}
```

## Test-Driven Development (TDD)

### The TDD Cycle: Red-Green-Refactor

1. **Red**: Write a failing test
2. **Green**: Write minimal code to make it pass
3. **Refactor**: Improve the code while keeping tests green

### Example TDD Workflow

```swift
// 1. RED: Write failing test
func test_Order_CalculateTotalPrice_ShouldSumAllItems() {
    let order = Order()
    order.add(appetizer1) // price: 8.99
    order.add(appetizer2) // price: 6.99
    
    XCTAssertEqual(order.totalPrice, 15.98, accuracy: 0.01)
}

// 2. GREEN: Implement minimal solution
class Order {
    var items: [Appetizer] = []
    
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.price }
    }
    
    func add(_ appetizer: Appetizer) {
        items.append(appetizer)
    }
}

// 3. REFACTOR: Improve while keeping tests green
```

## Best Practices

### Test Organization

```swift
class AppetizerModelTests: XCTestCase {
    // MARK: - Test Properties
    var appetizer: Appetizer!
    
    // MARK: - Setup & Teardown
    override func setUpWithError() throws {
        appetizer = Appetizer(/* test data */)
    }
    
    override func tearDownWithError() throws {
        appetizer = nil
    }
    
    // MARK: - Initialization Tests
    func test_AppetizerInitialization_ShouldHaveCorrectProperties() {
        // Test implementation
    }
    
    // MARK: - Validation Tests
    func test_AppetizerValidation_WithInvalidData_ShouldFail() {
        // Test implementation
    }
}
```

### Test Naming Convention

Use descriptive names following this pattern:
```
test_[MethodOrFeature]_[Scenario]_[ExpectedResult]
```

Examples:
- `test_EmailValidation_WithInvalidEmail_ShouldReturnFalse`
- `test_OrderCalculation_WithMultipleItems_ShouldReturnCorrectTotal`
- `test_NetworkRequest_WithServerError_ShouldShowAlert`

### AAA Pattern (Arrange-Act-Assert)

```swift
func test_AddItemToOrder_ShouldIncreaseItemCount() {
    // Arrange (Given)
    let order = Order()
    let appetizer = TestDataFactory.createTestAppetizer()
    
    // Act (When)
    order.add(appetizer)
    
    // Assert (Then)
    XCTAssertEqual(order.items.count, 1)
    XCTAssertEqual(order.items.first?.id, appetizer.id)
}
```

### Test Data Management

```swift
struct TestDataFactory {
    static func createTestAppetizer() -> Appetizer {
        return Appetizer(
            id: 999,
            name: "Test Appetizer",
            description: "Test description",
            price: 9.99,
            imageURL: "https://test.com/image.jpg",
            calories: 300,
            protein: 20,
            carbs: 25
        )
    }
    
    static func createTestAppetizers(count: Int) -> [Appetizer] {
        return (1...count).map { index in
            Appetizer(
                id: index,
                name: "Test Appetizer \(index)",
                description: "Test description \(index)",
                price: Double(index) * 2.99,
                imageURL: "https://test.com/image\(index).jpg",
                calories: 100 + (index * 50),
                protein: 10 + index,
                carbs: 15 + index
            )
        }
    }
}
```

## Advanced Testing Techniques

### Testing Async Code

```swift
func test_NetworkCall_ShouldReturnData() async throws {
    // Given
    let networkManager = NetworkManager()
    
    // When
    let appetizers = try await networkManager.fetchAppetizers()
    
    // Then
    XCTAssertFalse(appetizers.isEmpty)
}
```

### Testing Published Properties

```swift
func test_ViewModelProperty_WhenChanged_ShouldPublishUpdate() {
    let expectation = XCTestExpectation(description: "Property should publish")
    var cancellables = Set<AnyCancellable>()
    
    viewModel.$isLoading
        .dropFirst()
        .sink { isLoading in
            expectation.fulfill()
        }
        .store(in: &cancellables)
    
    viewModel.isLoading = true
    
    wait(for: [expectation], timeout: 1.0)
}
```

### Performance Testing

```swift
func test_OrderCalculation_Performance() {
    let order = Order()
    let appetizers = TestDataFactory.createTestAppetizers(count: 1000)
    
    appetizers.forEach { order.add($0) }
    
    measure {
        _ = order.totalPrice
    }
}
```

### Testing Error Conditions

```swift
func test_NetworkManager_WithInvalidURL_ShouldThrowError() async {
    let networkManager = NetworkManager()
    
    await XCTAssertThrowsError(try await networkManager.fetchAppetizers()) { error in
        XCTAssertTrue(error is APError)
        XCTAssertEqual(error as? APError, .invalidURL)
    }
}
```

## Running and Organizing Tests

### Running Tests

1. **All Tests**: `Cmd + U`
2. **Single Test**: Click diamond next to test method
3. **Test Class**: Click diamond next to class name
4. **Command Line**: `xcodebuild test`

### Test Plans

Create test plans to organize different test suites:
1. File → New → Test Plan
2. Configure which tests to include
3. Set different configurations (Debug/Release)

### Continuous Integration

Example GitHub Actions workflow:
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v2
    - name: Run tests
      run: xcodebuild test -project Appetizers.xcodeproj -scheme Appetizers -destination 'platform=iOS Simulator,name=iPhone 14'
```

## Common Testing Patterns

### Dependency Injection

```swift
// Instead of
class ViewModel {
    private let networkManager = NetworkManager.shared
}

// Use
class ViewModel {
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
}
```

### Test Doubles

- **Mock**: Programmable fake that verifies behavior
- **Stub**: Provides predetermined responses
- **Fake**: Working implementation with shortcuts
- **Spy**: Records information about calls

### Code Coverage

Enable code coverage:
1. Edit Scheme → Test
2. Check "Gather coverage for all targets"
3. View coverage in Report Navigator

Aim for:
- **Models/Utilities**: 90%+
- **ViewModels**: 80%+
- **Views**: Focus on critical paths

## Troubleshooting Common Issues

### Issue: Tests are slow
**Solution**: Use mocks instead of real network calls

### Issue: Flaky UI tests
**Solution**: Use proper waits and expectations

### Issue: Hard to test ViewModels
**Solution**: Inject dependencies, separate business logic

### Issue: Test data management
**Solution**: Use factories and builders

## Getting Started Checklist

- [ ] Add Unit Test target to your project
- [ ] Add UI Test target to your project
- [ ] Create first model test
- [ ] Create mock for network manager
- [ ] Test ViewModel with mock
- [ ] Add basic UI test for navigation
- [ ] Set up test data factories
- [ ] Configure code coverage
- [ ] Run tests in CI/CD

Remember: Start small, be consistent, and gradually build your testing skills! 