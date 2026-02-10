//
//  user.swift
//  Appetizers
//
//  Created by Sathya Kumar on 26/07/25.
//


import SwiftUI

struct User: Codable {
    
    var firstName = ""
    var lastName = ""
    var email = ""
    var birthDay = Date()
    var extraNapkins =  false
    var frequentRefills = false
    
    // Test-only property to simulate encoding failure
    var shouldFailEncoding = false
    
    func encode(to encoder: Encoder) throws {
        if shouldFailEncoding {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Test encoding failure"))
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(birthDay, forKey: .birthDay)
        try container.encode(extraNapkins, forKey: .extraNapkins)
        try container.encode(frequentRefills, forKey: .frequentRefills)
        // Don't encode shouldFailEncoding as it's test-only
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        email = try container.decode(String.self, forKey: .email)
        birthDay = try container.decode(Date.self, forKey: .birthDay)
        extraNapkins = try container.decode(Bool.self, forKey: .extraNapkins)
        frequentRefills = try container.decode(Bool.self, forKey: .frequentRefills)
        shouldFailEncoding = false // Always false when decoding
    }
    
    init(firstName: String = "", lastName: String = "", email: String = "", birthDay: Date = Date(), extraNapkins: Bool = false, frequentRefills: Bool = false, shouldFailEncoding: Bool = false) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.birthDay = birthDay
        self.extraNapkins = extraNapkins
        self.frequentRefills = frequentRefills
        self.shouldFailEncoding = shouldFailEncoding
    }
    
    private enum CodingKeys: String, CodingKey {
        case firstName, lastName, email, birthDay, extraNapkins, frequentRefills
    }
}
