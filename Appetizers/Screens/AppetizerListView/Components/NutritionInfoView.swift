//
//  NutritionInfoView.swift
//  Appetizers
//
//  Created by Sathya Kumar on 26/07/25.
//

import SwiftUI

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
    HStack(spacing: 40) {
        NutritionInfoView(title: "Calories", value: 300)
        NutritionInfoView(title: "Carbs", value: 15)
        NutritionInfoView(title: "Protein", value: 25)
    }
    .padding()
} 