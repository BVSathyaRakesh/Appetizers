//
//  NetworkManagerTests.swift
//  AppetizersTests
//
//  Created by Sathya Kumar on 29/09/25.
//

import XCTest
@testable import Appetizers

final class NetworkManagerTests: XCTestCase {
    
    // MARK: - Properties
    var networkManager: NetworkManager!
    var mockHTTPClient: MockHTTPClient!
    var mockJSONDecoder: MockJSONDecoderService!
    var mockImageDownloader: MockImageDownloader!
    var mockURLBuilder: MockURLBuilder!
    
    // MARK: - Setup & Teardown
    override func setUpWithError() throws {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        mockJSONDecoder = MockJSONDecoderService()
        mockImageDownloader = MockImageDownloader()
        mockURLBuilder = MockURLBuilder()
        
        networkManager = NetworkManager(
            httpClient: mockHTTPClient,
            jsonDecoder: mockJSONDecoder,
            imageDownloader: mockImageDownloader,
            urlBuilder: mockURLBuilder
        )
    }

    override func tearDownWithError() throws {
        networkManager = nil
        mockHTTPClient = nil
        mockJSONDecoder = nil
        mockImageDownloader = nil
        mockURLBuilder = nil
        super.tearDown()
    }
    
    // MARK: - fetchRequest Tests
    
    func testFetchRequest_Success() async throws {
        // Given
        let endpoint = "appetizers"
        let expectedURL = URL(string: "http://localhost:3000/swiftui-fundamentals/appetizers")!
        let expectedData = try JSONEncoder().encode(AppetizerResponse.mock)
        
        mockURLBuilder.mockURL = expectedURL
        mockHTTPClient.mockData = expectedData
        mockJSONDecoder.mockResult = AppetizerResponse.mock
        
        // When
        let result = try await networkManager.fetchRequest(from: endpoint, responseType: AppetizerResponse.self)
        
        // Then
        XCTAssertEqual(mockURLBuilder.capturedEndpoint, endpoint)
        XCTAssertEqual(mockHTTPClient.capturedURL, expectedURL)
        XCTAssertTrue(mockJSONDecoder.capturedType is AppetizerResponse.Type)
        XCTAssertEqual(result.request.count, AppetizerResponse.mock.request.count)
        XCTAssertEqual(result.request.first?.id, AppetizerResponse.mock.request.first?.id)
    }
    
    func testFetchRequest_URLBuilderThrowsError() async throws {
        // Given
        let endpoint = "invalid-endpoint"
        mockURLBuilder.shouldThrowError = true
        mockURLBuilder.errorToThrow = APError.invalidURL
        
        // When & Then
        do {
            _ = try await networkManager.fetchRequest(from: endpoint, responseType: AppetizerResponse.self)
            XCTFail("Expected error to be thrown")
        } catch let error as APError {
            XCTAssertEqual(error, APError.invalidURL)
            XCTAssertEqual(mockURLBuilder.capturedEndpoint, endpoint)
            XCTAssertFalse(mockHTTPClient.performRequestCalled)
        } catch {
            XCTFail("Expected APError.invalidURL, got \(error)")
        }
    }
    
    func testFetchRequest_HTTPClientThrowsError() async throws {
        // Given
        let endpoint = "appetizers"
        let expectedURL = URL(string: "http://localhost:3000/swiftui-fundamentals/appetizers")!
        
        mockURLBuilder.mockURL = expectedURL
        mockHTTPClient.shouldThrowError = true
        mockHTTPClient.errorToThrow = APError.unableToComplete
        
        // When & Then
        do {
            _ = try await networkManager.fetchRequest(from: endpoint, responseType: AppetizerResponse.self)
            XCTFail("Expected error to be thrown")
        } catch let error as APError {
            XCTAssertEqual(error, APError.unableToComplete)
            XCTAssertEqual(mockHTTPClient.capturedURL, expectedURL)
            XCTAssertFalse(mockJSONDecoder.decodeCalled)
        } catch {
            XCTFail("Expected APError.unableToComplete, got \(error)")
        }
    }
    
    func testFetchRequest_JSONDecoderThrowsError() async throws {
        // Given
        let endpoint = "appetizers"
        let expectedURL = URL(string: "http://localhost:3000/swiftui-fundamentals/appetizers")!
        let mockData = Data("invalid json".utf8)
        
        mockURLBuilder.mockURL = expectedURL
        mockHTTPClient.mockData = mockData
        mockJSONDecoder.shouldThrowError = true
        mockJSONDecoder.errorToThrow = APError.invalidData
        
        // When & Then
        do {
            _ = try await networkManager.fetchRequest(from: endpoint, responseType: AppetizerResponse.self)
            XCTFail("Expected error to be thrown")
        } catch let error as APError {
            XCTAssertEqual(error, APError.invalidData)
            XCTAssertEqual(mockJSONDecoder.capturedData, mockData)
        } catch {
            XCTFail("Expected APError.invalidData, got \(error)")
        }
    }
    
    // MARK: - downloadImage Tests
    
    func testDownloadImage_Success() async throws {
        // Given
        let urlString = "https://example.com/image.jpg"
        let expectedImage = UIImage(systemName: "photo")!
        
        mockImageDownloader.mockImage = expectedImage
        
        // When
        let result = try await networkManager.downloadImage(from: urlString)
        
        // Then
        XCTAssertEqual(mockImageDownloader.capturedURLString, urlString)
        XCTAssertEqual(result, expectedImage)
    }
    
    func testDownloadImage_ThrowsError() async throws {
        // Given
        let urlString = "invalid-url"
        mockImageDownloader.shouldThrowError = true
        mockImageDownloader.errorToThrow = APError.invalidURL
        
        // When & Then
        do {
            _ = try await networkManager.downloadImage(from: urlString)
            XCTFail("Expected error to be thrown")
        } catch let error as APError {
            XCTAssertEqual(error, APError.invalidURL)
            XCTAssertEqual(mockImageDownloader.capturedURLString, urlString)
        } catch {
            XCTFail("Expected APError.invalidURL, got \(error)")
        }
    }
    
    func testDownloadImage_ReturnsNil() async throws {
        // Given
        let urlString = "https://example.com/nonexistent.jpg"
        mockImageDownloader.mockImage = nil
        
        // When
        let result = try await networkManager.downloadImage(from: urlString)
        
        // Then
        XCTAssertNil(result)
        XCTAssertEqual(mockImageDownloader.capturedURLString, urlString)
    }
}

// MARK: - Mock Implementations

class MockHTTPClient: HTTPClientProtocol {
    var mockData: Data = Data()
    var shouldThrowError = false
    var errorToThrow: Error = APError.unableToComplete
    
    // Captured values for verification
    var capturedURL: URL?
    var performRequestCalled = false
    
    func performRequest(url: URL) async throws -> Data {
        performRequestCalled = true
        capturedURL = url
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockData
    }
}

class MockJSONDecoderService: JSONDecoderServiceProtocol {
    var mockResult: Any?
    var shouldThrowError = false
    var errorToThrow: Error = APError.invalidData
    
    // Captured values for verification
    var capturedType: Any.Type?
    var capturedData: Data?
    var decodeCalled = false
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        decodeCalled = true
        capturedType = type
        capturedData = data
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let result = mockResult as? T else {
            throw APError.invalidData
        }
        
        return result
    }
}

class MockImageDownloader: ImageDownloaderProtocol {
    var mockImage: UIImage?
    var shouldThrowError = false
    var errorToThrow: Error = APError.invalidURL
    
    // Captured values for verification
    var capturedURLString: String?
    var downloadImageCalled = false
    
    func downloadImage(from urlString: String) async throws -> UIImage? {
        downloadImageCalled = true
        capturedURLString = urlString
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockImage
    }
}

class MockURLBuilder: URLBuilderProtocol {
    var mockURL: URL = URL(string: "http://localhost:3000/swiftui-fundamentals/")!
    var shouldThrowError = false
    var errorToThrow: Error = APError.invalidURL
    
    // Captured values for verification
    var capturedEndpoint: String?
    var buildURLCalled = false
    
    func buildURL(from endpoint: String) throws -> URL {
        buildURLCalled = true
        capturedEndpoint = endpoint
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockURL
    }
}
