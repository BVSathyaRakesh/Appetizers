//
//  MyFirstTest.swift
//  AppetizersTests
//
//  Your learning journey starts here!
//

import XCTest
@testable import Appetizers

final class MyFirstTest: XCTestCase {
    
    // TODO: Write your first test here!
    func test_MyFirstTest() {
        // Your challenge: Make this test pass!
        
        // 1. Create two numbers
        let firstNumber = 10// TODO: Put a number here
        let secondNumber =  20// TODO: Put another number here
        
        // 2. Add them together
        let result =  firstNumber + secondNumber// TODO: Add the numbers
        
        // 3. Check if the result is correct
        XCTAssertEqual(result, 30/* TODO: What should the result be? */)
    }
} 
