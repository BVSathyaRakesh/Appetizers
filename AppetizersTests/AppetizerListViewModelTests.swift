//
//  AppetizerListViewModelTests.swift
//  AppetizersTests
//
//  Testing ViewModel with Dependency Injection
//

import XCTest
@testable import Appetizers

@MainActor
final class AppetizerListViewModelTests: XCTestCase {
    
    // MARK: - Test Properties
    var viewModel: AppetizerListViewModel!
    var mockNetworkManager: MockNetworkManager!
    
    // MARK: - Setup & Teardown
    override func setUpWithError() throws {
        mockNetworkManager = MockNetworkManager()
        // 🎯 KEY: Inject the mock dependency!
        viewModel = AppetizerListViewModel(networkManager: mockNetworkManager)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockNetworkManager = nil
    }
    
    // MARK: - Initialization Tests
    func test_Initialization_ShouldHaveCorrectInitialState() {
        // Then
        XCTAssertTrue(viewModel.appetizers.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.alertItem)
        XCTAssertFalse(viewModel.isShowingDetail)
        XCTAssertNil(viewModel.selectedAppetizer)
    }
    
    // MARK: - Success Cases
    func test_GetAppetizers_WithSuccessfulResponse_ShouldUpdateAppetizers() async {
        // Given
        let testAppetizers = TestDataFactory.createTestAppetizers(count: 3)
        mockNetworkManager.setupSuccessResponse(with: testAppetizers)
        
        // When
        viewModel.getAppetizers()
        
        // Wait for async operation to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(viewModel.appetizers.count, 3)
        XCTAssertEqual(viewModel.appetizers[0].name, "Test Appetizer 1")
        XCTAssertEqual(viewModel.appetizers[1].name, "Test Appetizer 2")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.alertItem)
        XCTAssertTrue(mockNetworkManager.fetchAppetizersCalled)
        XCTAssertEqual(mockNetworkManager.fetchAppetizersCallCount, 1)
    }
    
    func test_GetAppetizers_ShouldSetLoadingStateCorrectly() async {
        // Given
        mockNetworkManager.setupSuccessResponse(with: TestDataFactory.createTestAppetizers())
        
        // When
        viewModel.getAppetizers()
        
        // Then - Loading should be true initially
        XCTAssertTrue(viewModel.isLoading)
        
        // Wait for completion
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then - Loading should be false after completion
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Error Cases
    func test_GetAppetizers_WithInvalidURL_ShouldShowAlert() async {
        // Given
        mockNetworkManager.setupErrorResponse(error: .invalidURL)
        
        // When
        viewModel.getAppetizers()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(viewModel.appetizers.isEmpty)
        XCTAssertNotNil(viewModel.alertItem, "Should show an alert for invalid URL error")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_GetAppetizers_WithInvalidData_ShouldShowAlert() async {
        // Given
        mockNetworkManager.setupErrorResponse(error: .invalidData)
        
        // When
        viewModel.getAppetizers()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(viewModel.appetizers.isEmpty)
        XCTAssertNotNil(viewModel.alertItem, "Should show an alert for invalid data error")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_GetAppetizers_WithInvalidResponse_ShouldShowAlert() async {
        // Given
        mockNetworkManager.setupErrorResponse(error: .invalidResponse)
        
        // When
        viewModel.getAppetizers()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNotNil(viewModel.alertItem, "Should show an alert for invalid response error")
    }
    
    func test_GetAppetizers_WithUnableToComplete_ShouldShowAlert() async {
        // Given
        mockNetworkManager.setupErrorResponse(error: .unableToComplete)
        
        // When
        viewModel.getAppetizers()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNotNil(viewModel.alertItem, "Should show an alert for unable to complete error")
    }
    
    // MARK: - Detail View Tests
    func test_ShowDetailView_ShouldSetSelectedAppetizerAndShowDetail() {
        // Given
        let testAppetizer = TestDataFactory.createTestAppetizer()
        
        // When
        viewModel.showDetailView(for: testAppetizer)
        
        // Then
        XCTAssertEqual(viewModel.selectedAppetizer?.id, testAppetizer.id)
        XCTAssertTrue(viewModel.isShowingDetail)
    }
    
    func test_HideDetailView_ShouldClearSelectedAppetizerAndHideDetail() {
        // Given
        let testAppetizer = TestDataFactory.createTestAppetizer()
        viewModel.showDetailView(for: testAppetizer)
        
        // When
        viewModel.hideDetailView()
        
        // Then
        XCTAssertNil(viewModel.selectedAppetizer)
        XCTAssertFalse(viewModel.isShowingDetail)
    }
    
    // MARK: - Multiple Calls Test
    func test_GetAppetizers_CalledMultipleTimes_ShouldTrackCallCount() async {
        // Given
        mockNetworkManager.setupSuccessResponse(with: TestDataFactory.createTestAppetizers())
        
        // When
        viewModel.getAppetizers()
        viewModel.getAppetizers()
        viewModel.getAppetizers()
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        XCTAssertEqual(mockNetworkManager.fetchAppetizersCallCount, 3)
    }
} 