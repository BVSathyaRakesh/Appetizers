//
//  CloseButtonView.swift
//  Appetizers
//
//  Created by Sathya Kumar on 26/07/25.
//

import SwiftUI

struct CloseButtonView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .foregroundStyle(Color(.white))
                    .frame(width: 30, height: 30)
                    .opacity(0.6)
                
                Image(systemName: "xmark")
                    .imageScale(.small)
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.black)
            }
        }
    }
}

#Preview {
    CloseButtonView {
        print("Close button tapped")
    }
    .padding()
} 