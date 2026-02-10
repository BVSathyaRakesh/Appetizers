//
//  RemoteImage.swift
//  Appetizers
//
//  Created by Sathya Kumar on 19/06/25.
//

import SwiftUI


final class ImageLoader: ObservableObject {
    
    @Published var image: Image? = nil
    private let imageDownloader: ImageDownloadProtocol
    
    init(imageDownloader: ImageDownloadProtocol = NetworkManager.shared) {
        self.imageDownloader = imageDownloader
    }
    
    func load(fromURLString urlString: String) {
        Task {
            do {
                if let uiImage = try await imageDownloader.downloadImage(from: urlString) {
                    await MainActor.run {
                        self.image = Image(uiImage: uiImage)
                    }
                }
            } catch {
                // Handle error silently - image will remain nil and placeholder will be shown
                print("Failed to load image from \(urlString): \(error)")
            }
        }
    }
}


struct RemoteImage: View {
    var image : Image?
    
    var body: some View {
        image?.resizable() ?? Image("food-placeholder").resizable()
    }
}


struct AppetizerRemoteImage: View {
    
    @StateObject  var imageLoader = ImageLoader()
    
    var urlString: String
    
    var body :some View {
        RemoteImage(image: imageLoader.image)
            .onAppear { imageLoader.load(fromURLString: urlString) }
    }
}
