//
//  AccountView.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/05/25.
//

import SwiftUI

struct AccountView: View {
    
    @StateObject var viewModel = AccountViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("First Name", text: $viewModel.users.firstName)
                    TextField("Last Name", text: $viewModel.users.lastName)
                    TextField("Email", text: $viewModel.users.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled(true)
                    DatePicker("Birthday", selection: $viewModel.users.birthDay, displayedComponents: .date)
                    
                    Button {
                        viewModel.saveChanges()
                    } label: {
                        Text("Save Changes")
                    }
                    .disabled(viewModel.isLoading)
                }
                
                Section("Request Headers") {
                    Toggle("Extra Napkins", isOn: $viewModel.users.extraNapkins)
                    Toggle("Frequent Refills", isOn: $viewModel.users.frequentRefills)
                }
                .toggleStyle(SwitchToggleStyle(tint: .brandprimary))
            }
            .navigationTitle("👨‍💼 Account")
            .onAppear {
                viewModel.loadUserData()
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingView()
                }
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
    AccountView()
}
