//
//  ImageCircle.swift
//  daisy
//
//  Created by Galina on 31/03/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ImageCircle: View {
    @Environment(\.imageCache) var cache: ImageCache
    
    var user: User?
    var imageURL: String? {
        get {
            if let imageURL = user?.image?.url {
                return imageURL
            } else {
                return nil
            }
        }
    }
    var imageFile: Image?
    var imageSize: ImageSize
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.dSurpriseColor)
                .frame(width: imageSize.size(), height: imageSize.size(), alignment: .center)
                .overlay(
                    Circle().stroke(Color.dDarkBlueColor, lineWidth: 2))
                .shadow(radius: 10)
            if let imageURL = imageURL {
                AsyncImage(
                    url: URL(string: imageURL)!,
                    cache: self.cache,
                    configuration: { $0
                        .resizable()
                        .renderingMode(.original) }
                )
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: imageSize.size(), height: imageSize.size(), alignment: .center)
                .overlay(
                    Circle().stroke(Color.dDarkBlueColor, lineWidth: 2))
                .shadow(radius: 10)
            } else if imageFile != nil {
                imageFile?
                    .renderingMode(.original)
                    .resizable()
                    .clipShape(Circle())
                    .scaledToFill()
                    .frame(width: imageSize.size(), height: imageSize.size(), alignment: .center)
                    .overlay(
                        Circle().stroke(Color.dDarkBlueColor, lineWidth: 2))
                    .shadow(radius: 10)
            } else {
                VStack {
                    Image(systemName: imageSize == ImageSize.itemEdit ? "camera" : "greetingcard")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                    if imageSize == ImageSize.itemEdit {
                        Text("Tap to select a picture")
                            .font(.headline)
                    }
                }.foregroundColor(.dSecondaryBackground)
            }
        }
        
//            image
//                .resizable()
//                .clipShape(Circle())
//                .overlay(
//                    Circle().stroke(Color("dDarkBlueColor"), lineWidth: 2))
//                .shadow(radius: 10)
//                .aspectRatio(contentMode: .fit)
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        ImageCircle(imageSize: .itemDetail)
            .previewLayout(.sizeThatFits)
    }
}
