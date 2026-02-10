//
//  Appetizer.swift
//  Appetizers
//
//  Created by Sathya Kumar on 30/05/25.
//

import Foundation


struct Appetizer: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let price: Double
    let imageURL: String
    let calories: Int
    let protein: Int
    let carbs: Int
}


struct AppetizerResponse: Codable {
    let request: [Appetizer]
}


struct MockData {
    
    static let sampleAppetizer = Appetizer(id: 0001,
                                           name: "Test Appetizer",
                                           description: "This is the description for my appetizer. It's yummy.",
                                           price: 9.99,
                                           imageURL: "https://seanallen-course-backend.herokuapp.com/images/appetizers/philly-cheesesteak-sliders.jpg",
                                           calories: 99,
                                           protein: 99,
                                           carbs: 99)
    
    static let appetizers       = [sampleAppetizer, sampleAppetizer, sampleAppetizer, sampleAppetizer]
    
    static let orderItemOne     = Appetizer(id: 0001,
                                           name: "Test Appetizer One",
                                           description: "This is the description for my appetizer. It's yummy.",
                                           price: 9.99,
                                           imageURL: "https://seanallen-course-backend.herokuapp.com/images/appetizers/philly-cheesesteak-sliders.jpg",
                                           calories: 99,
                                           protein: 99,
                                           carbs: 99)
    
    static let orderItemTwo     = Appetizer(id: 0002,
                                           name: "Test Appetizer Two",
                                           description: "This is the description for my appetizer. It's yummy.",
                                           price: 9.99,
                                           imageURL: "https://seanallen-course-backend.herokuapp.com/images/appetizers/philly-cheesesteak-sliders.jpg",
                                           calories: 99,
                                           protein: 99,
                                           carbs: 99)
    
    static let orderItemThree   = Appetizer(id: 0003,
                                           name: "Test Appetizer Three",
                                           description: "This is the description for my appetizer. It's yummy.",
                                           price: 9.99,
                                           imageURL: "https://seanallen-course-backend.herokuapp.com/images/appetizers/philly-cheesesteak-sliders.jpg",
                                           calories: 99,
                                           protein: 99,
                                           carbs: 99)
    
    static let orderItems       = [orderItemOne, orderItemTwo, orderItemThree]
}


extension AppetizerResponse {
    static let mock = AppetizerResponse(request: [
        Appetizer(
            id: 1,
            name: "Spring Rolls",
            description: "Crispy rolls stuffed with vegetables and served with sweet chili sauce.",
            price: 5.99,
            imageURL: "https://example.com/springrolls.jpg",
            calories: 200,
            protein: 5,
            carbs: 25
        ),
        Appetizer(
            id: 2,
            name: "Chicken Wings",
            description: "Juicy wings tossed in a spicy buffalo sauce.",
            price: 8.49,
            imageURL: "https://example.com/chickenwings.jpg",
            calories: 450,
            protein: 30,
            carbs: 10
        ),
        Appetizer(
            id: 3,
            name: "Mozzarella Sticks",
            description: "Golden fried mozzarella with marinara dip.",
            price: 6.75,
            imageURL: "https://example.com/mozzarellasticks.jpg",
            calories: 320,
            protein: 12,
            carbs: 28
        )
    ])
}

