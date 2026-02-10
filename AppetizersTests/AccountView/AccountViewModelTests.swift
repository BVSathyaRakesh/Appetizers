//
//  AccountViewModelTests.swift
//  AppetizersTests
//
//  Created by Sathya Kumar on 28/09/25.
//

import XCTest
@testable import Appetizers

final class AccountViewModelTests: XCTestCase {
    
    // MARK: - Test Properties
    var viewModel: AccountViewModel!

    override func setUpWithError() throws {
        viewModel = AccountViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func test_saveChanges_whenFormIsInvalid_doesNotChangeState() {
        
        let initialUser = User(firstName:"",lastName: "",email: "",birthDay: Date())
        viewModel.users = initialUser
        viewModel.isLoading = false
        viewModel.alertItem = nil
        
        viewModel.saveChanges()
        
        // Verify that the state remains unchanged when form is invalid
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.users.firstName, initialUser.firstName)
        XCTAssertEqual(viewModel.users.lastName, initialUser.lastName)
        XCTAssertEqual(viewModel.users.email, initialUser.email)
        XCTAssertNotNil(viewModel.alertItem) // Should show invalid form alert
        
    }
    
    
    func test_saveChanges_successfulEncoding_setsUserDataAndSuccessAlert() {
        
        let initialUser = User(firstName:"Rakesh",lastName: "Sathya",email: "abc@gmail.com",birthDay: Date())
        
        viewModel.users = initialUser
        viewModel.isLoading = true
        viewModel.alertItem = AlertContext.userSaveSuccess
        
        viewModel.saveChanges()
 
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.users)
        XCTAssertEqual(viewModel.alertItem, AlertContext.userSaveSuccess)
        
    }
    
    
    func test_saveChanges_whenFormValidationFails_setsInvalidFormAlert() {
        
        let initialUser = User(firstName:"",lastName: "",email: "",birthDay: Date())
        
        viewModel.users = initialUser
        viewModel.isLoading = false
        viewModel.alertItem = nil
        
        viewModel.saveChanges()
 
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.users)
        XCTAssertEqual(viewModel.alertItem, AlertContext.invalidForm)
        
    }
    
    func test_saveChanges_whenEmailIsInvalid_setsInvalidEmailAlert() {
        
        let initialUser = User(firstName:"John", lastName: "Doe", email: "invalid-email", birthDay: Date())
        
        viewModel.users = initialUser
        viewModel.isLoading = false
        viewModel.alertItem = nil
        
        viewModel.saveChanges()
 
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.users)
        XCTAssertEqual(viewModel.alertItem, AlertContext.invalidEmail)
        
    }
    
    
    func test_saveChanges_whenEncodingFails_setsInvalidUserDataAlert() {
        
        // Set up valid form data but with encoding failure flag
        viewModel.users = User(firstName: "John", lastName: "Doe", email: "john@example.com", birthDay: Date(), shouldFailEncoding: true)
        viewModel.isLoading = false
        viewModel.alertItem = nil
        
        // Act - this will trigger encoding failure in the original saveChanges method
        viewModel.saveChanges()
        
        // Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.alertItem, AlertContext.invalidUserData)
    }

    
    func test_loadUserData_whenNoUserDataExists_returnsEarly() {
        
        // Arrange: Ensure no user data exists in UserDefaults
        UserDefaults.standard.removeObject(forKey: "user")
        
        let initialUser = viewModel.users
        viewModel.alertItem = nil
        
        // Act
        viewModel.loadUserData()
        
        // Assert - should return early without changing anything
        XCTAssertEqual(viewModel.users.firstName, initialUser.firstName)
        XCTAssertEqual(viewModel.users.lastName, initialUser.lastName)
        XCTAssertEqual(viewModel.users.email, initialUser.email)
        XCTAssertNil(viewModel.alertItem) // No alert should be set
    }
    
    func test_loadUserData_whenValidDataExists_loadsUserSuccessfully() {
        
        // Arrange: Set valid user data in UserDefaults
        let testUser = User(firstName: "John", lastName: "Doe", email: "john@example.com", birthDay: Date())
        let validData = try! JSONEncoder().encode(testUser)
        UserDefaults.standard.set(validData, forKey: "user")
        
        viewModel.alertItem = nil
        
        // Act
        viewModel.loadUserData()
        
        // Assert
        XCTAssertEqual(viewModel.users.firstName, testUser.firstName)
        XCTAssertEqual(viewModel.users.lastName, testUser.lastName)
        XCTAssertEqual(viewModel.users.email, testUser.email)
        XCTAssertNil(viewModel.alertItem) // No alert should be set for successful load
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "user")
    }
    
    func test_loadUserData_whenInvalidDataExists_setsInvalidUserDataAlert() {
        
        // Arrange: Set invalid JSON data in UserDefaults
        let invalidData = "invalid json data".data(using: .utf8)!
        UserDefaults.standard.set(invalidData, forKey: "user")
        
        viewModel.alertItem = nil
        
        // Act
        viewModel.loadUserData()
        
        // Assert
        XCTAssertEqual(viewModel.alertItem, AlertContext.invalidUserData)
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "user")
    }
    
    func test_resetForm_resetsAllUserFieldsToDefaults() {
        
        // Arrange: Set user data to non-default values
        viewModel.users.firstName = "John"
        viewModel.users.lastName = "Doe"
        viewModel.users.email = "john@example.com"
        viewModel.users.birthDay = Calendar.current.date(byAdding: .year, value: -25, to: Date())!
        viewModel.users.extraNapkins = true
        viewModel.users.frequentRefills = true
        
        // Act
        viewModel.resetForm()
        
        // Assert - all fields should be reset to default values
        XCTAssertEqual(viewModel.users.firstName, "")
        XCTAssertEqual(viewModel.users.lastName, "")
        XCTAssertEqual(viewModel.users.email, "")
        XCTAssertFalse(viewModel.users.extraNapkins)
        XCTAssertFalse(viewModel.users.frequentRefills)
        
        // For birthDay, we need to check it's approximately equal to current date
        // since Date() creates a new timestamp each time
        let timeDifference = abs(viewModel.users.birthDay.timeIntervalSince(Date()))
        XCTAssertLessThan(timeDifference, 1.0, "Birthday should be reset to current date")
    }
    
    func test_resetForm_whenFieldsAlreadyEmpty_remainsEmpty() {
        
        // Arrange: Ensure fields are already at default values
        viewModel.users.firstName = ""
        viewModel.users.lastName = ""
        viewModel.users.email = ""
        viewModel.users.birthDay = Date()
        viewModel.users.extraNapkins = false
        viewModel.users.frequentRefills = false
        
        // Act
        viewModel.resetForm()
        
        // Assert - fields should remain at default values
        XCTAssertEqual(viewModel.users.firstName, "")
        XCTAssertEqual(viewModel.users.lastName, "")
        XCTAssertEqual(viewModel.users.email, "")
        XCTAssertFalse(viewModel.users.extraNapkins)
        XCTAssertFalse(viewModel.users.frequentRefills)
        
        // Birthday should still be approximately current date
        let timeDifference = abs(viewModel.users.birthDay.timeIntervalSince(Date()))
        XCTAssertLessThan(timeDifference, 1.0, "Birthday should remain as current date")
    }

}
