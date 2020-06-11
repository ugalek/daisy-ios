//
//  ItemRow.swift
//  daisy
//
//  Created by Galina on 22/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ItemRow: View {
    enum DisplayMode {
        case compact, large
    }
    
    let displayMode: DisplayMode
    var item: Item
    
    var body: some View {
        HStack {
            if displayMode == .compact {
                HStack {
                    item.imageStored
                        .resizable()
                        .frame(width: 50, height: 50)
                    if item.status == 3 {
                        Text(item.title)
                            .foregroundColor(.gray)
                    } else {
                        Text(item.title)
                    }
                    Spacer()
                    
                    if item.status == 2 {
                        // reserved
                        Image(systemName: "gift")
                            .imageScale(.medium)
                            .foregroundColor(.purple)
                    } else if item.status == 3 {
                        // taken
                        Image(systemName: "gift.fill")
                            .imageScale(.medium)
                            .foregroundColor(.gray)
                    }
                }
            } else {
                VStack {
                    Image(item.image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                        .overlay(PriceOverlay(item: item))
                    Text(item.title)
                        .font(.footnote)
                        .lineLimit(1)
                }
            }
        }
    }
}

struct PriceOverlay: View {
    var item: Item
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [Color.black.opacity(0.6), Color.black.opacity(0)]),
            startPoint: .bottom,
            endPoint: .center)
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(gradient)
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text(String(item.price ?? 0))
                }
                .padding()
            }
        }
        .foregroundColor(.white)
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ItemRow(displayMode: ItemRow.DisplayMode.compact, item: itemData[0])
            ItemRow(displayMode: ItemRow.DisplayMode.compact, item: itemData[1])
            ItemRow(displayMode: ItemRow.DisplayMode.compact, item: itemData[2])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
