//
//  NetworkManager.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/05/25.
//

import UIKit

// MARK: - Protocol for Dependency Injection
protocol NetworkManagerProtocol {
    func fetchAppetizers() async throws -> [Appetizer]
    func downloadImages(imageURL urlString: String, completed: @escaping (UIImage?) -> Void)
}

// MARK: - NetworkManager Implementation
final class NetworkManager: NetworkManagerProtocol {
    
    static let shared = NetworkManager()
    
    private let cache = NSCache<NSString, UIImage>()
    static let baseURL = "http://localhost:3000/swiftui-fundamentals/"
    private let appetizerURL = baseURL + "appetizers"
    
    private init() {}
        
    func fetchAppetizers()  async throws -> [Appetizer] {
        
        guard let url = URL(string: appetizerURL) else {
            throw APError.invalidURL
        }
        
        let (data,_) = try await URLSession.shared.data(from: url)
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(AppetizerResponse.self, from: data).request
        } catch{
            throw APError.invalidData
        }
    }
    
    
    func downloadImages(imageURL urlString: String, completed: @escaping (UIImage?) -> Void){
        
        let cacheKey = NSString(string: urlString)
        
        if let cachedImage = cache.object(forKey: cacheKey) {
            completed(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            
            guard let data = data, let image = UIImage(data: data) else {
                completed(nil)
                return
            }
            
            self.cache.setObject(image, forKey: cacheKey)
            completed(image)
        }
        task.resume()
    }
}


