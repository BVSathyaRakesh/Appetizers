//
//  ResponseHandler.swift
//  Appetizers
//
//  Created by Sathya Kumar on 27/09/25.
//

import Foundation

// MARK: - Response Validator Protocol
protocol ResponseValidatorProtocol {
    func validate(_ response: URLResponse) throws
}

// MARK: - Response Validator Implementation
final class ResponseValidator: ResponseValidatorProtocol {
    func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            switch httpResponse.statusCode {
            case 400...499:
                throw APError.invalidURL
            case 500...599:
                throw APError.unableToComplete
            default:
                throw APError.invalidResponse
            }
        }
    }
}

// MARK: - JSON Decoder Service Protocol
protocol JSONDecoderServiceProtocol {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

// MARK: - JSON Decoder Service Implementation
final class JSONDecoderService: JSONDecoderServiceProtocol {
    private let decoder: JSONDecoder
    
    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw APError.invalidData
        }
    }
}
