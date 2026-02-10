//
//  AppetizerListView.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/05/25.
//

import SwiftUI

struct AppetizerListView: View {
    
    @StateObject private var viewModel = AppetizerListViewModel()
    @EnvironmentObject var serviceContainer: AppetizerServiceContainer
    @EnvironmentObject var router: Router
    
    var body: some View {
        ZStack {
            NavigationStack(path: router.path(for: .home)) {
                List(viewModel.appetizers) { appetizer in
                    AppetizerListCell(appetizer: appetizer)
                       // .listRowSeparator(.hidden)
                        .listRowSeparatorTint(.brandPrimary)
                        .onTapGesture {
                            viewModel.showDetailView(for: appetizer)
                        }
                }
                .navigationTitle("🍟 Appetizers")
                .disabled(viewModel.isShowingDetail)
                .listStyle(.plain)
            }
            .task {
                // Configure the service from environment
                viewModel.configureService(serviceContainer.service)
                viewModel.getAppetizers()
            }
            .blur(radius: viewModel.isShowingDetail ? 20 : 0)
            
            if viewModel.isShowingDetail {
                AppetizerDetailsView(
                    appetizer: viewModel.selectedAppetizer!,
                    isShowingDetail: $viewModel.isShowingDetail
                )
            }
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: alertItem.title,
                  message: alertItem.message,
                  dismissButton: alertItem.dismissButton)
        }
    }
}

#Preview {
    AppetizerListView()
        .environmentObject(Router())
        .environmentObject(AppetizerServiceContainer())
}
