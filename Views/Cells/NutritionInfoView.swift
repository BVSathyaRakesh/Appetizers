//
//  NutritionInfoView.swift
//  Appetizers
//
//  Created by Sathya Kumar on 26/07/25.
//

import SwiftUI

// MARK: - Component Views
struct NutritionInfoView: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
            
            Text("\(value)")
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
                .italic()
        }
    }
}

#Preview {
    NutritionInfoView(title: "Protein", value: 20)
}
