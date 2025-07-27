//
//  EmptyState.swift
//  Appetizers
//
//  Created by Sathya Kumar on 27/07/25.
//

import SwiftUI

struct EmptyState: View {
    
    let title:String
    let imageName:String
    
    var body: some View {
        ZStack{
            Color(.systemBackground)
                .ignoresSafeArea(.all)
            VStack() {
               
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.secondary)
                    .padding()
            }
            .offset(y: -50)
        }
    }
}

#Preview {
    EmptyState(title: "This is a little long text \n to test the default state", imageName: "empty-order")
}
