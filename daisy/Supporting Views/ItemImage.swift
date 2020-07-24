//
//  ItemImage.swift
//  daisy
//
//  Created by Galina on 19/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

public enum ImageSize {
    case itemRow
    case itemLargeRow
    case itemEdit
    case itemDetail
    
    public func size() -> CGFloat {
        switch self {
        case .itemRow:
            return 50
        case .itemLargeRow:
            return DaisyService.shared.mainWidth / 2 - 40
        case .itemEdit:
            return DaisyService.shared.mainWidth / 1.8
        case .itemDetail:
            return DaisyService.shared.mainWidth / 2 - 20
        }
    }
}

struct ItemImage: View {
    @Environment(\.imageCache) var cache: ImageCache
    
    var item: Item?
    var list: UserList?
    var imageFile: Image?
    var imageSize: ImageSize
    
    var imageURL: String {
        get {
            if let imageURL = item?.image?.url {
                return imageURL
            } else if let imageURL = list?.image?.url {
                return imageURL
            } else {
                return "/"
            }
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.dSurpriseColor)
                .frame(width: imageSize.size(), height: imageSize.size(), alignment: .center)
            if let imageURL = item?.image?.url {
                AsyncImage(
                    url: URL(string: imageURL)!,
                    cache: self.cache,
                    configuration: { $0
                        .resizable()
                        .renderingMode(.original) }
                )
                .scaledToFill()
                .frame(width: imageSize.size(), height: imageSize.size())
                .cornerRadius(8)
                .clipped()
            } else if imageFile != nil {
                imageFile?
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageSize.size(), height: imageSize.size())
                    .cornerRadius(8)
                    .clipped()
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
        .overlay(ItemImageOverlay(imageSize: imageSize, item: item))
    }
}

struct ItemImageOverlay: View {
    var imageSize: ImageSize
    var item: Item?
    
    private var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [Color.black.opacity(0.7), Color.black.opacity(0)]),
            startPoint: .bottomTrailing,
            endPoint: .topLeading)
    }
    
    private var itemRowView: some View {
        VStack {
            if item?.status != 1 {
                ZStack(alignment: .bottomLeading) {
                    Rectangle().fill(gradient)
                        .cornerRadius(8)
                    HStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Image(systemName: "gift.fill")
                                .imageScale(.medium)
                                .foregroundColor(Item.getIconColor(status: item?.status ?? 1))
                        }
                    }
                }
                .foregroundColor(.white)
            }
        }
    }
    
    private var itemLargeRowView: some View {
        VStack {
            if let item = item {
                PriceOverlay(item: item)
            }
        }
    }
    
    private var itemDetailView: some View {
        VStack {
            if item?.status != 1 {
                VStack {
                    ZStack {
                        Rectangle()
                            .trim(from: 0, to: 1)
                            .foregroundColor(Item.getBandColor(status: item?.status ?? 1))
                            .aspectRatio(CGSize(width: imageSize.size(), height: imageSize.size() / 3), contentMode: .fit)
                            .opacity(0.8)
                            .cornerRadius(8)
                        
                        Text(Item.getRawStatus(status: item?.status ?? 1))
                            .font(.headline)
                            .padding()
                        
                    }
                    Spacer()
                }
            }
        }
    }
    
    var body: some View {
        switch imageSize {
        case .itemRow: return AnyView(itemRowView)
        case .itemLargeRow: return AnyView(itemLargeRowView)
        case .itemEdit: return AnyView(VStack{})
        case .itemDetail: return AnyView(itemDetailView)
        }
    }
}

struct ItemImage_Previews: PreviewProvider {
    static var previews: some View {
        ItemImage(imageSize: .itemEdit)
    }
}
