//
//  AddToOrderButton.swift
//  Appetizers
//
//  Created by Sathya Kumar on 26/07/25.
//

import SwiftUI

struct AddToOrderButton: View {
    let price: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("$\(price, specifier: "%.2f") - Add to orders")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(width: 250, height: 50)
                .foregroundStyle(.white)
                .background(Color.brandprimary)
                .clipShape(RoundedRectangle(cornerRadius: 3.0))
        }
        .padding(.bottom, 30)
    }
}


