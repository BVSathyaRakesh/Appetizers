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
    private var appetizerService: AppetizerServiceProtocol
    
    // MARK: - Initializer
    init(appetizerService: AppetizerServiceProtocol = AppetizerService()) {
        self.appetizerService = appetizerService
    }
    
    // MARK: - Service Configuration
    func configureService(_ service: AppetizerServiceProtocol) {
        self.appetizerService = service
    }
    
    
    // MARK: - Network Methods
    func getAppetizers() {
        isLoading = true
        
        Task{
            do {
                appetizers = try await appetizerService.fetchAppetizers().request
                isLoading = false
            } catch {
                isLoading = false
                handleNetworkError(error)
            }
        }
    }
    
    func retryNetworkRequest() {
        getAppetizers()
    }
    
    // MARK: - Private Methods
    
    private func handleNetworkError(_ error: Error) {
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


