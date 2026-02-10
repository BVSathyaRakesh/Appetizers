//
//  AppetizerResponseMock.swift
//  AppetizersTests
//
//  Created by Sathya Kumar on 29/09/25.
//

import Foundation
@testable import Appetizers


// MARK: - Mock Services

class MockAppetizerService: AppetizerServiceProtocol {
    
    func fetchAppetizers() async throws -> AppetizerResponse {
        let mockData = AppetizerResponse.mock
        return mockData
    }
}

class MockAppetizerServiceWithError: AppetizerServiceProtocol {
    
    private let errorType: APError
    
    init(errorType: APError) {
        self.errorType = errorType
    }
    
    func fetchAppetizers() async throws -> AppetizerResponse {
        throw errorType
    }
}

class MockAppetizerServiceWithGenericError: AppetizerServiceProtocol {
    
    enum GenericError: Error {
        case someGenericError
    }
    
    func fetchAppetizers() async throws -> AppetizerResponse {
        throw GenericError.someGenericError
    }
}
