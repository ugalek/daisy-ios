//
//  GiftImage.swift
//  daisy
//
//  Created by Galina on 01/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct GiftImage: View {
    @Environment(\.imageCache) var cache: ImageCache
    
    var item: Item
    
    var body: some View {
        HStack {
            ZStack(alignment: .bottomLeading) {
                if item.status == 2 {
                    // reserved
                    if let imageURL = item.image?.url {
                        AsyncImage(
                            url: URL(string: imageURL)!,
                            cache: self.cache,
                            placeholder: Text("Loading ..."),
                            configuration: { $0.resizable() }
                        )
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                        .clipped()
                        .overlay(ColorOverlay(picColor: Color.dSecondaryButton))
                    } else {
                        Image("NoImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                            .clipped()
                            .overlay(ColorOverlay(picColor: Color.dSecondaryButton))
                    }
                } else if item.status == 3 {
                    // taken
                    if let imageURL = item.image?.url {
                        AsyncImage(
                            url: URL(string: imageURL)!,
                            cache: self.cache,
                            placeholder: Text("Loading ..."),
                            configuration: { $0.resizable() }
                        )
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                        .clipped()
                        .overlay(ColorOverlay(picColor: Color.gray))
                    } else {
                        Image("NoImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                            .clipped()
                            .overlay(ColorOverlay(picColor: Color.gray))
                    }
                }
            }
        }
    }
}

struct ColorOverlay: View {
    var picColor: Color
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [Color.black.opacity(0.7), Color.black.opacity(0)]),
            startPoint: .bottomTrailing,
            endPoint: .topLeading)
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(gradient)
                .cornerRadius(8)
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    Image(systemName: "gift.fill")
                    .imageScale(.medium)
                    .foregroundColor(picColor)
                }
            }
        }
        .foregroundColor(.white)
    }
}


struct GiftImage_Previews: PreviewProvider {
    static var previews: some View {
        GiftImage(item: staticReservedItem)
            .previewLayout(.sizeThatFits)
    }
}
