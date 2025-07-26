//
//  OrderView.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/05/25.
//

import SwiftUI

struct OrderView: View {
    
    @State private var orderItems = MockData.orderItems
    
    var body: some View {
        NavigationStack {
            VStack{
                List{
                    ForEach(orderItems) { item in
                        AppetizerListCell(appetizer: item)
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(PlainListStyle())
                
                AddToOrderButton(price: 9.99, title: "Place Order") {
                    
                }
                .padding(.bottom,30)
            }
            
            .navigationTitle("🧾 Order")
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        orderItems.remove(atOffsets: offsets)
    }
}

#Preview {
    OrderView()
}
