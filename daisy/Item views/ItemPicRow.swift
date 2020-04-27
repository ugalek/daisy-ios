//
//  ItemPicRow.swift
//  daisy
//
//  Created by Galina on 27/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ItemPicRow: View {
    var item: Item
    
    var body: some View {
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

struct ItemPicRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ItemPicRow(item: itemData[0])
            ItemPicRow(item: itemData[1])
            ItemPicRow(item: itemData[2])
        }
        .previewLayout(.sizeThatFits)
    }
}

