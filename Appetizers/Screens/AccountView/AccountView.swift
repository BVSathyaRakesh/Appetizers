//
//  AccountView.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/05/25.
//

import SwiftUI

struct AccountView: View {
    
    @StateObject var viewModel = AccountViewModel()
    @FocusState private var focusedField: FormTextField?
    
    enum FormTextField {
        case firstName, lastName, email
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("First Name", text: $viewModel.users.firstName)
                        .focused($focusedField, equals: .firstName)
                        .onSubmit { focusedField = .lastName }
                        .submitLabel(.next)
                    
                    TextField("Last Name", text: $viewModel.users.lastName)
                        .focused($focusedField, equals: .lastName)
                        .onSubmit { focusedField = .email }
                        .submitLabel(.next)
                    
                    TextField("Email", text: $viewModel.users.email)
                        .focused($focusedField, equals: .email)
                        .onSubmit { focusedField = nil }
                        .submitLabel(.continue)
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
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Dismiss") {  focusedField = nil }
                }
            }
            .navigationTitle("👨‍💼 Account")
            
        }
        .onAppear {
            viewModel.loadUserData()
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
