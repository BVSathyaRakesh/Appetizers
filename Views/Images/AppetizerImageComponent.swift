//
//  AppetizerImageComponent.swift
//  Appetizers
//
//  Created by Sathya Kumar on 26/07/25.
//

import SwiftUI

struct AppetizerImageComponent: View {
    let urlString: String
    let width: CGFloat
    let height: CGFloat
    
    init(urlString: String, width: CGFloat = 300, height: CGFloat = 200) {
        self.urlString = urlString
        self.width = width
        self.height = height
    }
    
    var body: some View {
        AppetizerRemoteImage(urlString: urlString)
            .frame(width: width, height: height)
            .aspectRatio(contentMode: .fit)
    }
}

