//
//  AppetizerMockHelper.swift
//  AppetizersUITests
//
//  Created by Sathya Kumar on 30/09/25.
//

import XCTest
@testable import Appetizers


extension  AppetizersListViewTests {
    
    
    // MARK: - Test App Helper (Inline)
    
    func createMockDataApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["APPETIZER_SERVICE_TYPE"] = "MOCK_SUCCESS"
        app.launch()
        return app
    }
    
    func createErrorApp(_ errorType: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["APPETIZER_SERVICE_TYPE"] = "MOCK_ERROR"
        app.launchEnvironment["ERROR_TYPE"] = errorType
        app.launch()
        return app
    }
    
    func createSlowNetworkApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["APPETIZER_SERVICE_TYPE"] = "MOCK_SUCCESS"
        app.launchEnvironment["NETWORK_DELAY"] = "3"
        app.launch()
        return app
    }
    
    func createProductionApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["APPETIZER_SERVICE_TYPE"] = "PRODUCTION"
        app.launch()
        return app
    }
        
    // MARK: - Helper Methods
    
    func navigateToAppetizerList(_ app: XCUIApplication) {
        let homeTab = app.tabBars.buttons["Home"]
        if homeTab.exists {
            homeTab.tap()
        }
    }
    
    func waitForAppetizerList(_ app: XCUIApplication) -> XCUIElement {
        let appetizerList = app.collectionViews.firstMatch
        XCTAssertTrue(appetizerList.waitForExistence(timeout: 10), "Appetizer list should be visible")
        return appetizerList
    }
    
    func waitForAlert(_ app: XCUIApplication) -> XCUIElement {
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 15), "Alert should appear")
        return alert
    }
    
    func verifyMockDataContent(in cells: XCUIElementQuery) {
        guard cells.count > 0 else { return }
        
        let firstCell = cells.element(boundBy: 0)
        let cellTexts = firstCell.staticTexts
        
        var foundMockData = false
        for i in 0..<cellTexts.count {
            let text = cellTexts.element(boundBy: i).label
            if text.contains("Spring Rolls") || text.contains("$5.99") {
                foundMockData = true
                break
            }
        }
        XCTAssertTrue(foundMockData, "Should display mock data (Spring Rolls, $5.99)")
    }
    
    func verifyErrorAlert(_ alert: XCUIElement, expectedTitle: String, expectedKeywords: [String]) {
        // Verify alert title
        let titleText = alert.staticTexts[expectedTitle]
        XCTAssertTrue(titleText.exists, "Alert should have '\(expectedTitle)' title")
        
        // Verify alert message contains expected keywords
        var foundKeyword = false
        for keyword in expectedKeywords {
            let messageText = alert.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", keyword)).firstMatch
            if messageText.exists {
                foundKeyword = true
                break
            }
        }
        XCTAssertTrue(foundKeyword, "Alert should contain expected message keywords")
        
        // Verify OK button exists
        let okButton = alert.buttons["OK"]
        XCTAssertTrue(okButton.exists, "OK button should exist")
    }
    
    func verifyEmptyListAfterError(_ app: XCUIApplication) {
        let appetizerList = app.collectionViews.firstMatch
        if appetizerList.exists {
            let cells = appetizerList.cells
            XCTAssertEqual(cells.count, 0, "Should show empty list after network error")
        }
    }
    
    func extractKeywords(from message: String) -> [String] {
        // Extract meaningful keywords from alert messages for testing
        let words = message.components(separatedBy: .punctuationCharacters.union(.whitespaces))
        return words.filter { $0.count > 3 } // Filter out short words
    }
    
}
