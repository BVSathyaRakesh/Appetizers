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
    
}
