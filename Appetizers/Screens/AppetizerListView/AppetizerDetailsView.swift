//
//  AppetizerDetailsView.swift
//  Appetizers
//
//  Created by Sathya Kumar on 26/07/25.
//

import SwiftUI

// MARK: - Main Detail View
struct AppetizerDetailsView: View {
    
    var appetizer: Appetizer
    
    @Binding var isShowingDetail: Bool
    
    var body: some View {
        VStack{
            VStack{
                AppetizerImageComponent(urlString: appetizer.imageURL)
                
                VStack{
                    VStack{
                        Text(appetizer.name)
                            .font(.title2)
                        
                        Text(appetizer.description)
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .padding()
                        
                        
                        HStack(spacing:40){
                            NutritionInfoView(title: "Calories", value: appetizer.calories)
                            NutritionInfoView(title: "Carbs", value: appetizer.carbs)
                            NutritionInfoView(title: "Protein", value: appetizer.protein)
                        }
                        
                    }
                    
                    Spacer()
                    
                    AddToOrderButton(price: appetizer.price,title:"Add to orders") {
                        // TODO: Add to order functionality
                    }
                    
                }
                
            }
        }
        .frame(width:300,height: 525)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius:5)
        .overlay (
            XDismissButton {
                isShowingDetail = false
            },
            alignment: .topTrailing
        )
        
    }
    
}



// MARK: - Preview
#Preview {
    AppetizerDetailsView(appetizer: MockData.sampleAppetizer, isShowingDetail: .constant(true))
}
