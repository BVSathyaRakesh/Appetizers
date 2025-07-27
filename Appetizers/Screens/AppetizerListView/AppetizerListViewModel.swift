//
//  AppetizerListViewModel.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/05/25.
//

import Foundation


@MainActor final class AppetizerListViewModel: ObservableObject {
    
    @Published var appetizers: [Appetizer] = []
    @Published var alertItem: AlertItem?
    @Published var isLoading = false
    @Published var isShowingDetail = false
    @Published var selectedAppetizer: Appetizer?
    
    // MARK: - Dependencies
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Initializer
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    // MARK: - Network Methods
    func getAppetizers() {
        isLoading = true
        Task{
            do {
                appetizers = try await networkManager.fetchAppetizers()
                isLoading = false
            }catch {
                isLoading = false
                if let apError = error as? APError {
                    switch apError {
                    case .invalidURL:
                        alertItem = AlertContext.invalidURL
                    case .invalidResponse:
                        alertItem = AlertContext.invalidResponse
                    case .invalidData:
                        alertItem = AlertContext.invalidData
                    case .unableToComplete:
                        alertItem = AlertContext.unableToComplete
                    }
                } else {
                    alertItem = AlertContext.invalidResponse
                }
            }
        }
    }
    
    // MARK: - Detail View Methods
    func showDetailView(for appetizer: Appetizer) {
        selectedAppetizer = appetizer
        isShowingDetail = true
    }
    
    func hideDetailView() {
        isShowingDetail = false
        selectedAppetizer = nil
    }
}


