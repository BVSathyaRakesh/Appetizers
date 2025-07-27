//
//  OrderView.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/05/25.
//

import SwiftUI

struct OrderView: View {
    
    @EnvironmentObject var order: Order
    
    var body: some View {
        
        NavigationStack {
            ZStack{
                VStack{
                    List{
                        ForEach(order.items) { item in
                            AppetizerListCell(appetizer: item)
                        }
                        .onDelete(perform: order.deleteItems)
                    }
                    .listStyle(PlainListStyle())
                    
                    AddToOrderButton(price: order.totalPrice, title: "Place Order") {
                        
                    }
                    .padding(.bottom,30)
                }
                if order.items.isEmpty {
                    EmptyState(title: "You have no items in your order. \n Please add some Appetizers", imageName: "empty-order")
                }
            }
            
            .navigationTitle("🧾 Order")
        }
    }
    
    
}

