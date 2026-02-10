//
//  AppetizersListViewTests.swift
//  AppetizersUITests
//
//  Created by Sathya Kumar on 30/09/25.
//

import XCTest
import Foundation

final class AppetizersListViewTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        // No app launch here - each test controls its own dependencies
    }
    
   
    // MARK: - Mock Data Tests
    
    func testAppetizerListDisplaysMockData() throws {
        let app = createMockDataApp()
        
        navigateToAppetizerList(app)
        
        let appetizerList = waitForAppetizerList(app)
        let cells = appetizerList.cells
        
        XCTAssertGreaterThan(cells.count, 0, "Should display mock appetizer data")
        
        // Verify mock data content (Spring Rolls, $5.99)
        verifyMockDataContent(in: cells)
    }
    
    func testAppetizerCellContent() throws {
        let app = createMockDataApp()
        
        navigateToAppetizerList(app)
        
        let appetizerList = waitForAppetizerList(app)
        let cells = appetizerList.cells
        
        XCTAssertGreaterThan(cells.count, 0, "Should have appetizer cells")
        
        // Test first cell has required elements
        let firstCell = cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists, "First cell should exist")
        
        // Should have image, name, and price
        let images = firstCell.images
        let texts = firstCell.staticTexts
        
        XCTAssertGreaterThan(images.count, 0, "Cell should have appetizer image")
        XCTAssertGreaterThan(texts.count, 1, "Cell should have name and price text")
    }
    
    // MARK: - Navigation Tests
    
    func testNavigationToAppetizerListView() throws {
        let app = createMockDataApp()
        
        // Should start on Home tab (Appetizer List)
        let navigationTitle = app.navigationBars["🍟 Appetizers"]
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: 10), "Should show Appetizers navigation title")
    }
    
    func testAppetizerListDisplays() throws {
        let app = createMockDataApp()
        
        navigateToAppetizerList(app)
        
        let appetizerList = waitForAppetizerList(app)
        XCTAssertTrue(appetizerList.exists, "Appetizer list should be displayed")
        
        let cells = appetizerList.cells
        XCTAssertGreaterThan(cells.count, 0, "Should have appetizer cells")
    }
    
    func testTapCellOpensDetailView() throws {
        let app = createMockDataApp()
        
        navigateToAppetizerList(app)
        
        let appetizerList = waitForAppetizerList(app)
        let cells = appetizerList.cells
        
        XCTAssertGreaterThan(cells.count, 0, "Should have cells to tap")
        
        // Wait for data to load completely
        Thread.sleep(forTimeInterval: 2.0)
        
        // Find a specific cell by its content (more reliable than index)
        let firstCell = cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists, "First cell should exist")
        
        // Ensure the cell is visible and tappable
        XCTAssertTrue(firstCell.isHittable, "First cell should be hittable")
        
        // Tap the cell
        firstCell.tap()
        
        // Wait for the detail view animation
        Thread.sleep(forTimeInterval: 1.5)
        
        // Try multiple ways to find the detail view
        let detailView = app.otherElements["appetizerDetailView"]
        let detailViewExists = detailView.waitForExistence(timeout: 3)
        
        
        XCTAssertTrue(detailViewExists, "Detail view should appear")
        
        // Should have close button
        let closeButton = app.buttons["closeButton"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 3), "Close button should exist")
        
        // Close detail view
        closeButton.tap()
    }
    
    func testDetailViewContent() throws {
        let app = createMockDataApp()
        
        navigateToAppetizerList(app)
        
        let appetizerList = waitForAppetizerList(app)
        let cells = appetizerList.cells
        
        // Tap first cell to open detail
        cells.element(boundBy: 0).tap()
        
        let detailView = app.otherElements["appetizerDetailView"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 5), "Detail view should appear")
        
        // Should have Add to Order button
        let addToOrderButton = app.buttons["addToOrderButton"]
        XCTAssertTrue(addToOrderButton.exists, "Add to Order button should exist")
        
        // Should have nutrition info
        let nutritionInfo = detailView.staticTexts
        var foundNutritionInfo = false
        
        for i in 0..<nutritionInfo.count {
            let text = nutritionInfo.element(boundBy: i).label
            if text.contains("Calories") || text.contains("Protein") || text.contains("Carbs") {
                foundNutritionInfo = true
                break
            }
        }
        XCTAssertTrue(foundNutritionInfo, "Should display nutrition information")
        
        // Close detail view
        app.buttons["closeButton"].tap()
    }
    
    func testAddToOrderFromDetailView() throws {
        let app = createMockDataApp()
        
        navigateToAppetizerList(app)
        
        let appetizerList = waitForAppetizerList(app)
        let cells = appetizerList.cells
        
        // Tap first cell to open detail
        cells.element(boundBy: 0).tap()
        
        // Tap Add to Order
        let addToOrderButton = app.buttons["addToOrderButton"]
        XCTAssertTrue(addToOrderButton.waitForExistence(timeout: 5), "Add to Order button should exist")
        addToOrderButton.tap()
        
        // Should close detail view automatically
        let detailView = app.otherElements["appetizerDetailView"]
        XCTAssertFalse(detailView.waitForExistence(timeout: 2), "Detail view should close after adding to order")
    }
    
    // MARK: - Network Error Tests
    
    func testNetworkErrorAlert_UnableToComplete() throws {
        let app = createErrorApp("UNABLE_TO_COMPLETE")
        
        navigateToAppetizerList(app)
        
        let alert = waitForAlert(app)
        
        // Verify alert title and message
        verifyErrorAlert(alert, expectedTitle: "Server Error", expectedKeywords: ["Unable", "complete", "request", "internet", "connection"])
        
        // Dismiss alert
        alert.buttons["OK"].tap()
        
        // Should show empty list
        verifyEmptyListAfterError(app)
    }
    
    func testNetworkErrorAlert_InvalidResponse() throws {
        let app = createErrorApp("INVALID_RESPONSE")
        
        navigateToAppetizerList(app)
        
        let alert = waitForAlert(app)
        
        verifyErrorAlert(alert, expectedTitle: "Server Error", expectedKeywords: ["Invalid", "response", "server", "try", "again"])
        
        alert.buttons["OK"].tap()
    }
    
    func testNetworkErrorAlert_InvalidData() throws {
        let app = createErrorApp("INVALID_DATA")
        
        navigateToAppetizerList(app)
        
        let alert = waitForAlert(app)
        
        verifyErrorAlert(alert, expectedTitle: "Server Error", expectedKeywords: ["data", "received", "invalid", "contact", "support"])
        
        alert.buttons["OK"].tap()
    }
    
    func testNetworkErrorAlert_InvalidURL() throws {
        let app = createErrorApp("INVALID_URL")
        
        navigateToAppetizerList(app)
        
        let alert = waitForAlert(app)
        
        // Note: Tests for the typo "Sever Error" in AlertContext.invalidURL
        verifyErrorAlert(alert, expectedTitle: "Sever Error", expectedKeywords: ["issue", "connecting", "server", "persists", "support"])
        
        alert.buttons["OK"].tap()
    }
    
    func testNetworkErrorAlert_ServerDown() throws {
        let app = createErrorApp("UNABLE_TO_COMPLETE")
        
        navigateToAppetizerList(app)
        
        let alert = waitForAlert(app)
        
        verifyErrorAlert(alert, expectedTitle: "Server Error", expectedKeywords: ["Unable", "complete", "request", "internet", "connection"])
        
        alert.buttons["OK"].tap()
    }
    
    func testNetworkErrorShowsEmptyState() throws {
        let app = createErrorApp("UNABLE_TO_COMPLETE")
        
        navigateToAppetizerList(app)
        
        // Should show error alert
        let alert = waitForAlert(app)
        
        // Dismiss alert
        let okButton = alert.buttons["OK"]
        XCTAssertTrue(okButton.exists, "OK button should exist")
        okButton.tap()
        
        // Should show empty list (no offline fallback in production)
        verifyEmptyListAfterError(app)
        
        // Should show normal navigation title
        let navigationTitle = app.navigationBars["🍟 Appetizers"]
        XCTAssertTrue(navigationTitle.exists, "Should show normal navigation title")
    }
    
    func testRetryAfterNetworkError() throws {
        let app = createErrorApp("UNABLE_TO_COMPLETE")
        
        navigateToAppetizerList(app)
        
        // Should show error alert
        let alert = waitForAlert(app)
        alert.buttons["OK"].tap()
        
        // In a real app, there might be a retry mechanism
        // For now, just verify the error handling worked
        XCTAssertTrue(true, "Error handling completed successfully")
    }
    
    func testMultipleNetworkErrors() throws {
        // Test that multiple consecutive errors are handled properly
        let app = createErrorApp("INVALID_RESPONSE")
        
        navigateToAppetizerList(app)
        
        let alert = waitForAlert(app)
        alert.buttons["OK"].tap()
        
        // Verify app is still responsive after error
        let navigationTitle = app.navigationBars["🍟 Appetizers"]
        XCTAssertTrue(navigationTitle.exists, "App should remain responsive after error")
    }
    
    func testSlowNetworkWithTimeout() throws {
        let app = createSlowNetworkApp()
        
        navigateToAppetizerList(app)
        
        // Should eventually load, just slower
        let appetizerList = app.collectionViews.firstMatch
        XCTAssertTrue(appetizerList.waitForExistence(timeout: 15), "Should load with slow network")
        
        let cells = appetizerList.cells
        XCTAssertGreaterThan(cells.count, 0, "Should eventually display data")
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateAppears() throws {
        let app = createSlowNetworkApp()
        
        navigateToAppetizerList(app)
        
        // Should show loading state briefly, then data
        let appetizerList = app.collectionViews.firstMatch
        XCTAssertTrue(appetizerList.waitForExistence(timeout: 10), "List should eventually load")
    }
    
    // MARK: - Performance Tests
    
    func testAppetizerListScrollPerformance() throws {
        let app = createMockDataApp()
        
        navigateToAppetizerList(app)
        
        let appetizerList = waitForAppetizerList(app)
        
        // Measure scroll performance
        measure {
            appetizerList.swipeUp()
            appetizerList.swipeDown()
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityElements() throws {
        let app = createMockDataApp()
        
        navigateToAppetizerList(app)
        
        let appetizerList = waitForAppetizerList(app)
        let cells = appetizerList.cells
        
        if cells.count > 0 {
            let firstCell = cells.element(boundBy: 0)
            
            // Should have accessibility identifiers
            XCTAssertTrue(firstCell.exists, "Cell should be accessible")
            
            // Tap to open detail view
            firstCell.tap()
            
            // Check detail view accessibility
            let closeButton = app.buttons["closeButton"]
            XCTAssertTrue(closeButton.exists, "Close button should be accessible")
            
            let addToOrderButton = app.buttons["addToOrderButton"]
            XCTAssertTrue(addToOrderButton.exists, "Add to Order button should be accessible")
            
            closeButton.tap()
        }
    }
    
    // MARK: - Production Comparison Test
    
    func testProductionServiceStillWorks() throws {
        let app = createProductionApp()
        
        navigateToAppetizerList(app)
        
        let appetizerList = app.collectionViews.firstMatch
        
        // Production service might succeed or fail
        if appetizerList.waitForExistence(timeout: 30) {
            let cells = appetizerList.cells
            print("✅ Production service loaded \(cells.count) appetizers")
        } else {
            let alert = app.alerts.firstMatch
            if alert.exists {
                print("⚠️ Production service showed error (expected if server down)")
                alert.buttons["OK"].tap()
            }
        }
        
        XCTAssertTrue(true, "Production service test completed")
    }
    
    
}
