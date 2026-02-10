//
//  AppetizerTabView.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/05/25.
//

import SwiftUI

struct AppetizerTabView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var order: Order
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            AppetizerListView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppTab.home)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person")
                }
                .tag(AppTab.account)
            
            OrderView()
                .tabItem {
                    Label("Order", systemImage: "bag")
                }
                .tag(AppTab.order)
                .badge(order.items.count)
        }
        .tint(.brandprimary)
    }
}

#Preview {
    AppetizerTabView()
        .environmentObject(Router())
        .environmentObject(Order())
        .environmentObject(AppetizerServiceContainer())
}
