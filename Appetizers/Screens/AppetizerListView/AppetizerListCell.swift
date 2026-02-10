//
//  AppetizerListCell.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/05/25.
//

import SwiftUI

struct AppetizerListCell: View {
    
    let appetizer : Appetizer
    
    var body: some View {
        HStack{
//            AppetizerRemoteImage(urlString: appetizer.imageURL)
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 120,height: 90)
//                .cornerRadius(10)
            
            AsyncImage(url: URL(string: appetizer.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120,height: 90)
                    .cornerRadius(8)
            } placeholder: {
                Image("food-placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120,height: 90)
                    .cornerRadius(8)
            }
            .accessibilityIdentifier("appetizerImage_\(appetizer.id)")

            
            VStack(alignment:.leading,spacing: 5){
                Text(appetizer.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("appetizerName_\(appetizer.id)")
                
                Text("$\(appetizer.price,specifier:"%.2f")")
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("appetizerPrice_\(appetizer.id)")
            }
            .padding(.leading)
        }
        .accessibilityIdentifier("appetizerCell_\(appetizer.id)")
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(appetizer.name), $\(appetizer.price, specifier: "%.2f")")
        .accessibilityHint("Double tap to view details")
    }
}

#Preview {
    AppetizerListCell(appetizer: MockData.sampleAppetizer)
}
