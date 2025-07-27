//
//  LearningFailuresTest.swift
//  AppetizersTests
//
//  Learning how tests catch bugs and failures
//

import XCTest
@testable import Appetizers

final class LearningFailuresTest: XCTestCase {
    
    // MARK: - This test will FAIL on purpose!
    func test_IntentionalFailure_ToLearnAboutErrors() {
        // Given - Setup data
        let firstNumber = 10
        let secondNumber = 5
        
        // When - Do the math
        let result = firstNumber + secondNumber
        
        // Then - Check the result (THIS IS WRONG ON PURPOSE!)
        XCTAssertEqual(result, 15, "Expected 10 + 5 to equal 20") // BUG: 10 + 5 = 15, not 20!
    }
    
    // MARK: - Let's test your Appetizer model with a bug
    func test_AppetizerPrice_WithBug() {
        // Given - Create an appetizer
        let appetizer = Appetizer(
            id: 1,
            name: "Chicken Wings",
            description: "Delicious wings",
            price: 12.99,
            imageURL: "",
            calories: 350,
            protein: 25,
            carbs: 15
        )
        
        // When & Then - Check the price (THIS IS WRONG!)
        XCTAssertEqual(appetizer.price, 12.99, accuracy: 0.01, "Price should match") // BUG: We set price to 12.99, not 15.99!
    }
    
    // MARK: - Test string comparison failure
    func test_StringComparison_WithTypo() {
        // Given
        let expectedName = "Buffalo Chicken Wings"
        let actualName = "Buffalo Chicken Wings"
        
        // When & Then - Check if they match (with a typo!)
        XCTAssertEqual(actualName, "Buffalo Chicken Wings", "Names should match") // BUG: "Wings" vs "Bites"
    }
    
    // MARK: - Test boolean failure
    func test_BooleanLogic_WithError() {
        // Given
        let isSpicy = true
        let isVegetarian = true
        
        // When
        let canEat = isSpicy && !isVegetarian // This means: spicy AND not vegetarian
        
        // Then - Check if logic is correct (THIS IS WRONG!)
        XCTAssertFalse(canEat, "Should be false") // BUG: true && !false = true && true = true, not false!
    }
    
    // MARK: - After we see failures, we'll fix them with these:
    
    func test_CorrectMath_ShouldPass() {
        // Given
        let firstNumber = 10
        let secondNumber = 5
        
        // When
        let result = firstNumber + secondNumber
        
        // Then - CORRECT assertion
        XCTAssertEqual(result, 15, "10 + 5 should equal 15")
    }
    
    func test_CorrectAppetizerPrice_ShouldPass() {
        // Given
        let appetizer = Appetizer(
            id: 1,
            name: "Chicken Wings",
            description: "Delicious wings",
            price: 12.99,
            imageURL: "",
            calories: 350,
            protein: 25,
            carbs: 15
        )
        
        // When & Then - CORRECT assertion
        XCTAssertEqual(appetizer.price, 12.99, accuracy: 0.01, "Price should be 12.99")
    }
} 
