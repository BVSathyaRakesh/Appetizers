//
//  NetworkManagerIntegrationTests.swift
//  AppetizersTests
//
//  Created by Sathya Kumar on 29/09/25.
//

import XCTest
@testable import Appetizers

final class NetworkManagerIntegrationTests: XCTestCase {
    
    // MARK: - Properties
    var networkManager: NetworkManager!
    var mockURLSession: MockURLSession!
    
    // MARK: - Setup & Teardown
    override func setUpWithError() throws {
        super.setUp()
        mockURLSession = MockURLSession()
        
        let httpClient = HTTPClient(session: mockURLSession)
        
        // Create ImageDownloader with the same mock HTTPClient for image download tests
        let imageDownloader = ImageDownloader(httpClient: httpClient)
        
        networkManager = NetworkManager(
            httpClient: httpClient,
            jsonDecoder: JSONDecoderService(),
            imageDownloader: imageDownloader,
            urlBuilder: URLBuilder()
        )
    }
    
    override func tearDownWithError() throws {
        networkManager = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    // MARK: - Integration Tests
    
    func testFetchAppetizers_SuccessfulIntegration() async throws {
        // Given
        let mockAppetizerResponse = AppetizerResponse.mock
        let mockData = try JSONEncoder().encode(mockAppetizerResponse)
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/swiftui-fundamentals/appetizers")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        mockURLSession.mockData = mockData
        mockURLSession.mockResponse = mockResponse
        
        // When
        let result = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
        
        // Then
        XCTAssertEqual(result.request.count, mockAppetizerResponse.request.count)
        XCTAssertEqual(result.request.first?.name, mockAppetizerResponse.request.first?.name)
        XCTAssertTrue(mockURLSession.dataTaskCalled)
    }
    
    func testFetchAppetizers_NetworkError() async throws {
        // Given
        mockURLSession.mockError = URLError(.notConnectedToInternet)
        
        // When & Then
        do {
            _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
            XCTFail("Expected network error to be thrown")
        } catch let error as APError {
            XCTAssertEqual(error, APError.unableToComplete)
        } catch {
            XCTFail("Expected APError.unableToComplete, got \(error)")
        }
    }
    
    func testFetchAppetizers_InvalidHTTPResponse() async throws {
        // Given
        let mockData = Data("some data".utf8)
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/swiftui-fundamentals/appetizers")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockURLSession.mockData = mockData
        mockURLSession.mockResponse = mockResponse
        
        // When & Then
        do {
            _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
            XCTFail("Expected invalid URL error to be thrown")
        } catch let error as APError {
            XCTAssertEqual(error, APError.invalidURL)
        } catch {
            XCTFail("Expected APError.invalidURL, got \(error)")
        }
    }
    
    func testFetchAppetizers_ServerError() async throws {
        // Given
        let mockData = Data("Internal Server Error".utf8)
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/swiftui-fundamentals/appetizers")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!
        
        mockURLSession.mockData = mockData
        mockURLSession.mockResponse = mockResponse
        
        // When & Then
        do {
            _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
            XCTFail("Expected server error to be thrown")
        } catch let error as APError {
            XCTAssertEqual(error, APError.unableToComplete)
        } catch {
            XCTFail("Expected APError.unableToComplete, got \(error)")
        }
    }
    
    func testFetchAppetizers_InvalidJSON() async throws {
        // Given
        let mockData = Data("invalid json data".utf8)
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/swiftui-fundamentals/appetizers")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        mockURLSession.mockData = mockData
        mockURLSession.mockResponse = mockResponse
        
        // When & Then
        do {
            _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
            XCTFail("Expected JSON decoding error to be thrown")
        } catch let error as APError {
            XCTAssertEqual(error, APError.invalidData)
        } catch {
            XCTFail("Expected APError.invalidData, got \(error)")
        }
    }
    
    func testDownloadImage_SuccessfulIntegration() async throws {
        // Given
        let imageURL = "https://example.com/test-image.jpg"
        let testImage = UIImage(systemName: "photo")!
        let imageData = testImage.pngData()!
        let mockResponse = HTTPURLResponse(
            url: URL(string: imageURL)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "image/png"]
        )!
        
        mockURLSession.mockData = imageData
        mockURLSession.mockResponse = mockResponse
        
        // When
        let result = try await networkManager.downloadImage(from: imageURL)
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertTrue(mockURLSession.dataTaskCalled)
    }
    
    // MARK: - Performance Tests
    
    func testFetchAppetizers_Performance() async throws {
        // Given
        let mockAppetizerResponse = AppetizerResponse.mock
        let mockData = try JSONEncoder().encode(mockAppetizerResponse)
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/swiftui-fundamentals/appetizers")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        mockURLSession.mockData = mockData
        mockURLSession.mockResponse = mockResponse
        
        // When & Then
        measure {
            let expectation = XCTestExpectation(description: "Network request completes")
            
            Task {
                do {
                    _ = try await networkManager.fetchRequest(from: "appetizers", responseType: AppetizerResponse.self)
                    expectation.fulfill()
                } catch {
                    XCTFail("Network request failed: \(error)")
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
}

// MARK: - MockURLSession

class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    // Captured values for verification
    var capturedRequest: URLRequest?
    var dataTaskCalled = false
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataTaskCalled = true
        capturedRequest = request
        
        if let error = mockError {
            throw error
        }
        
        let data = mockData ?? Data()
        let response = mockResponse ?? HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return (data, response)
    }
}
