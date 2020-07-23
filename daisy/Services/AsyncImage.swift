//
//  AsyncImage.swift
//  daisy
//
//  Created by Galina on 16/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

// See www.vadimbulavin.com/asynchronous-swiftui-image-loading-from-url-with-combine-and-swift/
struct AsyncImage: View {
    @ObservedObject private var loader: ImageLoader
    private let configuration: (Image) -> Image
    
    init(url: URL, cache: ImageCache? = nil, configuration: @escaping (Image) -> Image = { $0 }) {
        loader = ImageLoader(url: url, cache: cache)
        self.configuration = configuration
    }

    var body: some View {
        image
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }
    
    private var image: some View {
        Group {
            if loader.image != nil {
                configuration(Image(uiImage: loader.image!))
            } else {
                Image(systemName: "hourglass")
                    .foregroundColor(.dSecondaryBackground)
            }
        }
    }
}
