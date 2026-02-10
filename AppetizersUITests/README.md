# UI Testing Guide for AppetizerListView

This document provides a comprehensive guide for UI testing the AppetizerListView and its components.

## Test Structure

The `AppetizersListViewTests` class contains comprehensive UI tests organized into the following categories:

### 1. Navigation Tests
- **testNavigationToAppetizerListView**: Verifies that the app launches and displays the appetizer list tab correctly.

### 2. List Display Tests
- **testAppetizerListDisplays**: Tests that the appetizer list loads and displays correctly.
- **testAppetizerCellContent**: Verifies that appetizer cells contain the expected content (name, price, image).

### 3. Detail View Tests
- **testTapCellOpensDetailView**: Tests that tapping an appetizer cell opens the detail view.
- **testDetailViewContent**: Verifies that the detail view displays all expected content.
- **testAddToOrderFromDetailView**: Tests the "Add to Order" functionality from the detail view.

### 4. Loading State Tests
- **testLoadingStateAppears**: Tests that loading indicators appear during data fetching.

### 5. Error Handling Tests
- **testNetworkErrorAlert_UnableToComplete**: Tests network connection error alerts.
- **testNetworkErrorAlert_InvalidResponse**: Tests invalid server response error alerts.
- **testNetworkErrorAlert_InvalidData**: Tests invalid data error alerts.
- **testNetworkErrorAlert_InvalidURL**: Tests invalid URL error alerts.
- **testNetworkErrorAlert_ServerDown**: Tests server down scenario alerts.
- **testEmptyStateWhenNetworkFails**: Tests empty state when network fails.
- **testRetryAfterNetworkError**: Tests retry functionality after network errors.
- **testMultipleNetworkErrors**: Tests handling of multiple consecutive errors.
- **testSlowNetworkWithTimeout**: Tests slow network conditions and timeouts.
- **testOfflineModeWithFallbackData**: Tests offline mode with fallback data display.
- **testPullToRefreshInOfflineMode**: Tests pull-to-refresh functionality in offline mode.
- **testOfflineDataContent**: Tests offline data content and interactions.
- **testOfflineToOnlineTransition**: Tests transition from offline to online mode.

### 6. Performance Tests
- **testAppetizerListScrollPerformance**: Measures scrolling performance.
- **testLaunchPerformance**: Measures app launch performance.

### 7. Accessibility Tests
- **testAccessibilityElements**: Verifies that UI elements are properly accessible.

## Accessibility Identifiers

The following accessibility identifiers have been added to improve test reliability:

### AppetizerListCell
- `appetizerCell_{id}`: The entire cell
- `appetizerImage_{id}`: The appetizer image
- `appetizerName_{id}`: The appetizer name text
- `appetizerPrice_{id}`: The appetizer price text

### AppetizerDetailsView
- `appetizerDetailView`: The entire detail view
- `addToOrderButton`: The "Add to Order" button

### XDismissButton
- `closeButton`: The close/dismiss button

## Running the Tests

### Prerequisites
1. Ensure your app is properly configured for UI testing
2. Make sure the local server is running if testing with real data
3. Consider adding launch arguments for test configurations

### Running Tests in Xcode
1. Open the project in Xcode
2. Select the test target (AppetizersUITests)
3. Use Cmd+U to run all tests or Cmd+Ctrl+U to run specific tests
4. Use the Test Navigator to run individual test methods

### Running Tests from Command Line
```bash
# Run all UI tests
xcodebuild test -project Appetizers.xcodeproj -scheme Appetizers -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' -only-testing:AppetizersUITests

# Run specific test class
xcodebuild test -project Appetizers.xcodeproj -scheme Appetizers -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' -only-testing:AppetizersUITests/AppetizersListViewTests

# Run specific test method
xcodebuild test -project Appetizers.xcodeproj -scheme Appetizers -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' -only-testing:AppetizersUITests/AppetizersListViewTests/testNavigationToAppetizerListView
```

## Test Configuration

### Launch Arguments
The tests use various launch arguments to configure the app for different testing scenarios:

#### Basic Testing
```swift
app.launchArguments = ["UI_TESTING"]
```

#### Network Error Simulation
```swift
// Simulate network connection error
app.launchArguments = ["UI_TESTING", "SIMULATE_NETWORK_ERROR"]

// Simulate invalid server response
app.launchArguments = ["UI_TESTING", "SIMULATE_INVALID_RESPONSE"]

// Simulate invalid data from server
app.launchArguments = ["UI_TESTING", "SIMULATE_INVALID_DATA"]

// Simulate invalid URL error
app.launchArguments = ["UI_TESTING", "SIMULATE_INVALID_URL"]

// Simulate server completely down
app.launchArguments = ["UI_TESTING", "SIMULATE_SERVER_DOWN"]

// Simulate slow network conditions
app.launchArguments = ["UI_TESTING", "SIMULATE_SLOW_NETWORK"]

// Simulate error then success on retry
app.launchArguments = ["UI_TESTING", "SIMULATE_NETWORK_ERROR_THEN_SUCCESS"]

// Simulate multiple consecutive errors
app.launchArguments = ["UI_TESTING", "SIMULATE_MULTIPLE_ERRORS"]

// Simulate offline mode with fallback data
app.launchArguments = ["UI_TESTING", "SIMULATE_OFFLINE_WITH_FALLBACK"]
```

### Environment Variables
You can also set environment variables for testing:

```swift
app.launchEnvironment = ["UITEST_MODE": "1"]
```

## Network Error Testing

### How Network Simulation Works

The app includes a `TestConfiguration` class and `MockAppetizerService` that can simulate various network conditions based on launch arguments:

1. **TestConfiguration**: Detects launch arguments and configures network simulation mode
2. **MockAppetizerService**: Replaces the real network service during testing
3. **AppetizerListViewModel**: Switches to mock service when in testing mode
4. **OfflineDataService**: Provides fallback data when network is unavailable

### Available Network Simulations

| Launch Argument | Error Type | Expected Alert |
|---|---|---|
| `SIMULATE_NETWORK_ERROR` | Network connection failure | "Unable to complete your request at this time. Please check your internet connection." |
| `SIMULATE_INVALID_RESPONSE` | Invalid server response | "Invalid response from the server. Please try again later or contact support." |
| `SIMULATE_INVALID_DATA` | Invalid JSON data | "The data received from the server was invalid. Please contact support." |
| `SIMULATE_INVALID_URL` | Invalid URL | "There was an issue connecting to the server. If this persists, please contact support." |
| `SIMULATE_SERVER_DOWN` | Server completely down | "Unable to complete your request at this time. Please check your internet connection." |
| `SIMULATE_SLOW_NETWORK` | Slow network (3s delay) | Eventually loads data or times out |
| `SIMULATE_NETWORK_ERROR_THEN_SUCCESS` | First request fails, retry succeeds | Error alert, then success on retry |
| `SIMULATE_MULTIPLE_ERRORS` | Multiple consecutive failures | Multiple error alerts |
| `SIMULATE_OFFLINE_WITH_FALLBACK` | Network failure with offline fallback | Shows offline data with user-friendly alert |

### Testing Network Error Scenarios

#### Basic Error Test Pattern
```swift
func testSpecificNetworkError() throws {
    // Launch with specific error simulation
    app.terminate()
    app.launchArguments = ["UI_TESTING", "SIMULATE_NETWORK_ERROR"]
    app.launch()
    
    navigateToAppetizerList()
    
    // Wait for error alert
    let alert = app.alerts.firstMatch
    XCTAssertTrue(alert.waitForExistence(timeout: 10))
    
    // Verify alert content
    XCTAssertTrue(alert.staticTexts["Server Error"].exists)
    
    // Dismiss alert
    alert.buttons["OK"].tap()
    
    // Verify app state after error
    XCTAssertTrue(app.navigationBars["🍟 Appetizers"].exists)
}
```

#### Testing Empty State After Error
```swift
func testEmptyStateAfterNetworkError() throws {
    // Launch with network error
    app.terminate()
    app.launchArguments = ["UI_TESTING", "SIMULATE_NETWORK_ERROR"]
    app.launch()
    
    navigateToAppetizerList()
    
    // Handle error alert
    let alert = app.alerts.firstMatch
    alert.waitForExistence(timeout: 10)
    alert.buttons["OK"].tap()
    
    // Verify empty state
    let appetizerList = app.collectionViews.firstMatch
    if appetizerList.exists {
        XCTAssertEqual(appetizerList.cells.count, 0)
    }
}
```

#### Testing Retry Functionality
```swift
func testRetryAfterError() throws {
    // Use error-then-success simulation
    app.terminate()
    app.launchArguments = ["UI_TESTING", "SIMULATE_NETWORK_ERROR_THEN_SUCCESS"]
    app.launch()
    
    navigateToAppetizerList()
    
    // Handle initial error
    let alert = app.alerts.firstMatch
    alert.waitForExistence(timeout: 10)
    alert.buttons["OK"].tap()
    
    // Trigger retry (pull to refresh or navigation)
    let appetizerList = app.collectionViews.firstMatch
    appetizerList.swipeDown() // Pull to refresh
    
    // Verify success on retry
    sleep(2)
    XCTAssertGreaterThan(appetizerList.cells.count, 0)
}
```

#### Testing Mock Offline Data (Testing Only)
```swift
func testOfflineModeWithFallbackData() throws {
    // Launch with offline fallback simulation (testing only)
    app.terminate()
    app.launchArguments = ["UI_TESTING", "SIMULATE_OFFLINE_WITH_FALLBACK"]
    app.launch()
    
    navigateToAppetizerList()
    
    // Verify mock offline data is displayed
    let appetizerList = app.collectionViews.firstMatch
    XCTAssertTrue(appetizerList.waitForExistence(timeout: 10))
    XCTAssertGreaterThan(appetizerList.cells.count, 0)
    
    // Verify test data contains "(Offline)" indicators
    let firstCell = appetizerList.cells.element(boundBy: 0)
    let cellTexts = firstCell.staticTexts
    
    var foundOfflineIndicator = false
    for i in 0..<cellTexts.count {
        let text = cellTexts.element(boundBy: i).label
        if text.contains("(Offline)") {
            foundOfflineIndicator = true
            break
        }
    }
    XCTAssertTrue(foundOfflineIndicator, "Should show test data with '(Offline)' indicator")
    
    // Verify normal navigation title (no special offline UI in production)
    XCTAssertTrue(app.navigationBars["🍟 Appetizers"].exists)
}
```

#### Testing Production Error Behavior
```swift
func testNetworkErrorShowsEmptyState() throws {
    // Test production behavior: network errors show empty state
    app.terminate()
    app.launchArguments = ["UI_TESTING", "SIMULATE_NETWORK_ERROR"]
    app.launch()
    
    navigateToAppetizerList()
    
    // Should show error alert
    let alert = app.alerts.firstMatch
    XCTAssertTrue(alert.waitForExistence(timeout: 10))
    alert.buttons["OK"].tap()
    
    // Should show empty list (no offline fallback in production)
    let appetizerList = app.collectionViews.firstMatch
    if appetizerList.exists {
        XCTAssertEqual(appetizerList.cells.count, 0)
    }
    
    // Should show normal navigation title
    XCTAssertTrue(app.navigationBars["🍟 Appetizers"].exists)
}
```

## Best Practices

### 1. Wait Strategies
- Use `waitForExistence(timeout:)` instead of `sleep()` when possible
- Set appropriate timeouts based on expected loading times
- Use conditional checks for elements that might not always be present

### 2. Element Selection
- Prefer accessibility identifiers over text-based selectors
- Use specific selectors to avoid ambiguity
- Test with different data sets to ensure robustness

### 3. Test Independence
- Each test should be independent and not rely on the state from previous tests
- Use proper setup and teardown methods
- Reset app state between tests if necessary

### 4. Error Handling
- Use conditional checks for elements that might not exist
- Provide meaningful assertion messages
- Handle network-dependent tests gracefully

## Extending the Tests

### Adding New Test Cases
1. Follow the existing naming convention: `test[Feature][Scenario]()`
2. Add appropriate accessibility identifiers to new UI elements
3. Use the helper methods like `navigateToAppetizerList()`
4. Group related tests under appropriate MARK comments

### Testing Network Scenarios
To test different network scenarios, consider:
1. Using mock data with launch arguments
2. Implementing network stubbing
3. Testing offline scenarios
4. Testing slow network conditions

### Testing Different Data States
- Empty state (no appetizers)
- Loading state
- Error state
- Different appetizer counts
- Various appetizer data formats

## Troubleshooting

### Common Issues
1. **Elements not found**: Check accessibility identifiers and element hierarchy
2. **Timing issues**: Increase timeouts or add proper wait conditions
3. **Simulator issues**: Reset simulator or use different device configurations
4. **Network dependencies**: Use mock data or ensure test server is running

### Debugging Tips
1. Use `po app.debugDescription` in debugger to see element hierarchy
2. Add breakpoints to inspect element states
3. Use Accessibility Inspector to verify element properties
4. Enable slow animations for better debugging

## Testing-Only Offline Mode

### Important Note

**Offline mode functionality is ONLY available during UI testing and is NOT part of the production app.** The production app shows standard error alerts when the server is unavailable.

### Testing Components

1. **MockAppetizerService**: 
   - Contains offline test data for UI testing scenarios
   - Provides 6 predefined appetizers with "(Offline)" indicators in names
   - Only activated when using `SIMULATE_OFFLINE_WITH_FALLBACK` launch argument

2. **Production Behavior**:
   - Network failures show standard error alerts
   - Empty list state when server is unavailable
   - No offline fallback or cached data
   - Standard retry mechanism through app restart or manual retry

### Testing Offline Scenarios

Use `SIMULATE_OFFLINE_WITH_FALLBACK` launch argument to test:
- Mock offline data display (for testing UI components)
- Interaction with test data when server is simulated as down
- Verification that UI can handle data display properly
- Testing detail view functionality with mock data

### Production vs Testing Behavior

| Scenario | Production App | Testing Mode |
|----------|----------------|--------------|
| Server Down | Shows error alert + empty list | Shows mock data with "(Offline)" labels |
| Network Error | Standard error handling | Can simulate various error types |
| Retry Mechanism | App restart or manual retry | Configurable through launch arguments |
| UI Indicators | Standard navigation title | Normal navigation title (no special indicators) |

## Continuous Integration

For CI/CD pipelines, consider:
1. Running tests on multiple device configurations
2. Generating test reports and screenshots
3. Setting up proper test data and mock services
4. Configuring appropriate timeouts for CI environments
5. Testing both online and offline scenarios

## Performance Considerations

- UI tests are slower than unit tests
- Run critical path tests more frequently
- Use test parallelization when possible
- Consider test execution time in CI/CD pipelines
- Offline mode tests are faster as they don't require network calls
