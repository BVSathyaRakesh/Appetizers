//
//  APError.swift
//  Appetizers
//
//  Created by Sathya Kumar on 18/06/25.
//

import Foundation

enum APError : Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case unableToComplete
    
    // MARK: - String Conversion for UI Tests
    static func from(string: String) -> APError {
        switch string {
        case "INVALID_URL":
            return .invalidURL
        case "INVALID_RESPONSE":
            return .invalidResponse
        case "INVALID_DATA":
            return .invalidData
        case "UNABLE_TO_COMPLETE":
            return .unableToComplete
        default:
            return .unableToComplete
        }
    }
}
