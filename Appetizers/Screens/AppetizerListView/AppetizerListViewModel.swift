//
//  AppetizerListViewModel.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/05/25.
//

import Foundation


class AppetizerListViewModel: ObservableObject {
    
    @Published var appetizers: [Appetizer] = []
    @Published var alertItem: AlertItem?
    @Published var isLoading = false
    @Published var isShowingDetail = false
    @Published var selectedAppetizer: Appetizer?
    
    // MARK: - Network Methods
    func getAppetizers() {
        isLoading = true
        NetworkManager.shared.fetchAppetizers { [self] result in
            DispatchQueue.main.sync {
                isLoading = false
                switch result {
                case .success(let appetizers):
                    self.appetizers = appetizers
                case .failure(let error):
                    switch error {
                    case .invalidURL:
                        alertItem = AlertContext.invalidURL
                    case .invalidResponse:
                        alertItem = AlertContext.invalidResponse
                    case .invalidData:
                        alertItem = AlertContext.invalidData
                    case .unableToComplete:
                        alertItem = AlertContext.unableToComplete
                    }
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


