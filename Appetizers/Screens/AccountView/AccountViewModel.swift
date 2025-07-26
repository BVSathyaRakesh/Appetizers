//
//  AccountViewModel.swift
//  Appetizers
//
//  Created by Sathya Kumar on 26/07/25.
//

import Foundation
import SwiftUI

class AccountViewModel: ObservableObject {
    
    @AppStorage("user") private var userData: Data?
    @Published var users = User()
    @Published var alertItem: AlertItem?
    @Published var isLoading: Bool = false
    
    // MARK: - Business Logic Methods
    func saveChanges() {
        guard isValidForm else { return }
        isLoading = true
        do {
            let data = try JSONEncoder().encode(users)
            userData = data
            self.isLoading = false
            self.alertItem = AlertContext.userSaveSuccess
        }catch {
            self.isLoading = false
            self.alertItem = AlertContext.invalidUserData
        }
    }
    
    // MARK: - Data Management
    func loadUserData() {
       
        guard let userData = userData else { return }
        
        do {
             users = try JSONDecoder().decode(User.self, from: userData)
        } catch {
            alertItem = AlertContext.invalidUserData
        }
        
    }
    
    // MARK: - Validation
    var isValidForm: Bool {
        guard !users.firstName.isEmpty && !users.lastName.isEmpty && !users.email.isEmpty else {
            alertItem = AlertContext.invalidForm
            return false
        }
        
        guard users.email.isValidEmail else {
            alertItem = AlertContext.invalidEmail
            return false
        }
        
        return true
    }
    
   
    
    func resetForm() {
        users.firstName = ""
        users.lastName = ""
        users.email = ""
        users.birthDay = Date()
        users.extraNapkins = false
        users.frequentRefills = false
    }
}
