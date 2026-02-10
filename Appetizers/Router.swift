//
//  Router.swift
//  Appetizers
//
//  Created by Sathya Kumar on 10/02/26.
//

import Foundation
import SwiftUI

enum AppRoute: Hashable {
    case home
    case profile(userId: String)
    case settings
}

enum AppTab: Hashable, CaseIterable {
    case home
    case account
    case order
}

final class Router: ObservableObject {
    // Tab selection
    @Published var selectedTab: AppTab = .home
    
    // Separate navigation paths for each tab
    @Published private var tabPaths: [AppTab: NavigationPath] = [:]
    
    init() {
        // Initialize all tab paths upfront to avoid mutations during view updates
        for tab in AppTab.allCases {
            tabPaths[tab] = NavigationPath()
        }
    }
    
    // Get navigation path binding for a specific tab
    func path(for tab: AppTab) -> Binding<NavigationPath> {
        return Binding(
            get: {
                // Safe access - path is guaranteed to exist after init
                self.tabPaths[tab] ?? NavigationPath()
            },
            set: { newValue in
                self.tabPaths[tab] = newValue
            }
        )
    }
    
    // MARK: - Tab Navigation
    
    func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }
    
    // MARK: - Route Navigation
    
    func push(_ route: AppRoute, to tab: AppTab? = nil) {
        let targetTab = tab ?? selectedTab
        ensurePathExists(for: targetTab)
        tabPaths[targetTab]?.append(route)
    }
    
    func pop(from tab: AppTab? = nil) {
        let targetTab = tab ?? selectedTab
        guard var path = tabPaths[targetTab], !path.isEmpty else { return }
        path.removeLast()
        tabPaths[targetTab] = path
    }
    
    func popToRoot(for tab: AppTab? = nil) {
        let targetTab = tab ?? selectedTab
        tabPaths[targetTab] = NavigationPath()
    }
    
    // MARK: - Private Helpers
    
    private func ensurePathExists(for tab: AppTab) {
        if tabPaths[tab] == nil {
            tabPaths[tab] = NavigationPath()
        }
    }
}
