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
    
    var viewModel : AppetizerListViewModel!
            
    // MARK: - Setup & Teardown
    override func setUpWithError() throws {
       
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    
    func testFetchAppetizersSuccess() async {
        //Arrange
        let mockService = MockAppetizerService()
        viewModel  = AppetizerListViewModel(appetizerService: mockService)
        viewModel.isLoading = true
        
        //Act
        viewModel.getAppetizers()
        
        // Wait for the async operation to complete
        try? await Task.sleep(for: .milliseconds(100))
        
        //Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.appetizers.isEmpty)
        XCTAssertNil(viewModel.alertItem)
    }
    
    func testFetchAppetizersFailure_InvalidURL() async {
        //Arrange
        let mockService = MockAppetizerServiceWithError(errorType: .invalidURL)
        viewModel = AppetizerListViewModel(appetizerService: mockService)
        viewModel.isLoading = true
        
        //Act
        viewModel.getAppetizers()
        
        // Wait for the async operation to complete
        try? await Task.sleep(for: .milliseconds(100))
        
        //Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.alertItem, AlertContext.invalidURL)
        XCTAssertTrue(viewModel.appetizers.isEmpty)
    }
    
    func testFetchAppetizersFailure_InvalidResponse() async {
        //Arrange
        let mockService = MockAppetizerServiceWithError(errorType: .invalidResponse)
        viewModel = AppetizerListViewModel(appetizerService: mockService)
        viewModel.isLoading = true
        
        //Act
        viewModel.getAppetizers()
        
        // Wait for the async operation to complete
        try? await Task.sleep(for: .milliseconds(100))
                
        //Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.alertItem, AlertContext.invalidResponse)
        XCTAssertTrue(viewModel.appetizers.isEmpty)
    }
    
    func testFetchAppetizersFailure_InvalidData() async {
        //Arrange
        let mockService = MockAppetizerServiceWithError(errorType: .invalidData)
        viewModel = AppetizerListViewModel(appetizerService: mockService)
        viewModel.isLoading = true
        
        //Act
        viewModel.getAppetizers()
        
        // Wait for the async operation to complete
        try? await Task.sleep(for: .milliseconds(100))
        
        //Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.alertItem, AlertContext.invalidData)
        XCTAssertTrue(viewModel.appetizers.isEmpty)
    }
    
    func testFetchAppetizersFailure_UnableToComplete() async {
        //Arrange
        let mockService = MockAppetizerServiceWithError(errorType: .unableToComplete)
        viewModel = AppetizerListViewModel(appetizerService: mockService)
        viewModel.isLoading = true
        
        //Act
        viewModel.getAppetizers()
        
        // Wait for the async operation to complete
        try? await Task.sleep(for: .milliseconds(100))
        
        //Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.alertItem, AlertContext.unableToComplete)
        XCTAssertTrue(viewModel.appetizers.isEmpty)
    }
    
    func testFetchAppetizersFailure_GenericError() async {
        //Arrange
        let mockService = MockAppetizerServiceWithGenericError()
        viewModel = AppetizerListViewModel(appetizerService: mockService)
        viewModel.isLoading = true
        
        //Act
        viewModel.getAppetizers()
        
        // Wait for the async operation to complete
        try? await Task.sleep(for: .milliseconds(100))
        
        //Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.alertItem, AlertContext.invalidResponse)
        XCTAssertTrue(viewModel.appetizers.isEmpty)
    }
    
    
    
    // MARK: - Detail View Tests
    
    func testShowDetailView_SetsSelectedAppetizerAndShowsDetail() {
        //Arrange
        let mockService = MockAppetizerService()
        viewModel = AppetizerListViewModel(appetizerService: mockService)
        let appetizer = MockData.sampleAppetizer
        
        // Verify initial state
        XCTAssertNil(viewModel.selectedAppetizer)
        XCTAssertFalse(viewModel.isShowingDetail)
        
        //Act
        viewModel.showDetailView(for: appetizer)
        
        //Assert
        XCTAssertNotNil(viewModel.selectedAppetizer)
        XCTAssertEqual(viewModel.selectedAppetizer?.id, appetizer.id)
        XCTAssertEqual(viewModel.selectedAppetizer?.name, appetizer.name)
        XCTAssertTrue(viewModel.isShowingDetail)
    }
    
    func testShowDetailView_WithDifferentAppetizer() {
        //Arrange
        let mockService = MockAppetizerService()
        viewModel = AppetizerListViewModel(appetizerService: mockService)
        
        let customAppetizer = Appetizer(
            id: 999,
            name: "Custom Test Appetizer",
            description: "A test appetizer for unit testing",
            price: 12.99,
            imageURL: "https://example.com/test.jpg",
            calories: 300,
            protein: 15,
            carbs: 20
        )
        
        //Act
        viewModel.showDetailView(for: customAppetizer)
        
        //Assert
        XCTAssertNotNil(viewModel.selectedAppetizer)
        XCTAssertEqual(viewModel.selectedAppetizer?.id, 999)
        XCTAssertEqual(viewModel.selectedAppetizer?.name, "Custom Test Appetizer")
        XCTAssertEqual(viewModel.selectedAppetizer?.price, 12.99)
        XCTAssertTrue(viewModel.isShowingDetail)
    }
    
    func testShowDetailView_OverwritesPreviousSelection() {
        //Arrange
        let mockService = MockAppetizerService()
        viewModel = AppetizerListViewModel(appetizerService: mockService)
        let firstAppetizer = MockData.sampleAppetizer
        let secondAppetizer = Appetizer(
            id: 2,
            name: "Second Appetizer",
            description: "Another test appetizer",
            price: 8.99,
            imageURL: "https://example.com/second.jpg",
            calories: 250,
            protein: 12,
            carbs: 18
        )
        
        // First selection
        viewModel.showDetailView(for: firstAppetizer)
        XCTAssertEqual(viewModel.selectedAppetizer?.id, firstAppetizer.id)
        
        //Act - Second selection should overwrite first
        viewModel.showDetailView(for: secondAppetizer)
        
        //Assert
        XCTAssertNotNil(viewModel.selectedAppetizer)
        XCTAssertEqual(viewModel.selectedAppetizer?.id, secondAppetizer.id)
        XCTAssertEqual(viewModel.selectedAppetizer?.name, "Second Appetizer")
        XCTAssertTrue(viewModel.isShowingDetail)
    }
    
    func testHideDetailView_ClearsSelectionAndHidesDetail() {
        //Arrange
        let mockService = MockAppetizerService()
        viewModel = AppetizerListViewModel(appetizerService: mockService)
        let appetizer = MockData.sampleAppetizer
        
        // First show detail
        viewModel.showDetailView(for: appetizer)
        XCTAssertNotNil(viewModel.selectedAppetizer)
        XCTAssertTrue(viewModel.isShowingDetail)
        
        //Act
        viewModel.hideDetailView()
        
        //Assert
        XCTAssertNil(viewModel.selectedAppetizer)
        XCTAssertFalse(viewModel.isShowingDetail)
    }
    
    func testHideDetailView_WhenNoDetailIsShowing() {
        //Arrange
        let mockService = MockAppetizerService()
        viewModel = AppetizerListViewModel(appetizerService: mockService)
        
        // Verify initial state
        XCTAssertNil(viewModel.selectedAppetizer)
        XCTAssertFalse(viewModel.isShowingDetail)
        
        //Act - Hide detail when nothing is showing
        viewModel.hideDetailView()
        
        //Assert - Should remain in initial state
        XCTAssertNil(viewModel.selectedAppetizer)
        XCTAssertFalse(viewModel.isShowingDetail)
    }
    
    func testDetailViewWorkflow_ShowThenHide() {
        //Arrange
        let mockService = MockAppetizerService()
        viewModel = AppetizerListViewModel(appetizerService: mockService)
        let appetizer = MockData.sampleAppetizer
        
        // Initial state
        XCTAssertNil(viewModel.selectedAppetizer)
        XCTAssertFalse(viewModel.isShowingDetail)
        
        //Act & Assert - Show detail
        viewModel.showDetailView(for: appetizer)
        XCTAssertNotNil(viewModel.selectedAppetizer)
        XCTAssertTrue(viewModel.isShowingDetail)
        
        //Act & Assert - Hide detail
        viewModel.hideDetailView()
        XCTAssertNil(viewModel.selectedAppetizer)
        XCTAssertFalse(viewModel.isShowingDetail)
    }
    
    
    func testWithExpectation() {
        let expectation = XCTestExpectation(description: "Fetch completes")
        
        // Arrange
        let mockService = MockAppetizerServiceWithError(errorType: .invalidResponse)
        viewModel = AppetizerListViewModel(appetizerService: mockService)
        viewModel.isLoading = true
        
        // Act
        viewModel.getAppetizers()
        
        // Use weak self to avoid retain cycles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else {
                expectation.fulfill()
                return
            }
            
            // Assert
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertEqual(self.viewModel.alertItem, AlertContext.invalidResponse)
            XCTAssertTrue(self.viewModel.appetizers.isEmpty)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
   
}



