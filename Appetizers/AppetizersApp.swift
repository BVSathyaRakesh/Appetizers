//
//  AppetizersApp.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/05/25.
//

import SwiftUI

@main
struct AppetizersApp: App {
    
    @StateObject private var router = Router()
    var order = Order()
    
    var body: some Scene {
        WindowGroup {
            AppetizerTabView()
                .environmentObject(router)
                .environmentObject(order)
                .environmentObject(AppetizerServiceContainer())
        }
    }
}


