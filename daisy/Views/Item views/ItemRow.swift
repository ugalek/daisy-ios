//
//  ItemRow.swift
//  daisy
//
//  Created by Galina on 22/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ItemRow: View {
    var item: Item
    
    var body: some View {
        HStack {
            if item.status == 1 {
                item.imageStored
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                Text(item.title)
                    .foregroundColor(.black)
                Spacer()
                Text(String(item.price ?? 0) + " $")
            } else if item.status == 2 {
                GiftImage(item: item)
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .foregroundColor(.black)
                    Text("Reserved")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(String(item.price ?? 0) + " $")
            } else {
                GiftImage(item: item)
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .foregroundColor(.gray)
                    Text("Taken")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
    }
}

struct PriceOverlay: View {
    var item: Item
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [Color.black.opacity(0.5), Color.black.opacity(0)]),
            startPoint: .bottom,
            endPoint: .center)
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(gradient)
                .cornerRadius(8)
            HStack {
                VStack(alignment: .leading) {
                    if item.status == 2 {
                        Text("Reserved")
                            .font(.footnote)
                    } else if item.status == 3 {
                        Text("Taken")
                            .font(.footnote)
                    }
                }
                .padding(.leading)
                
                Spacer()
                VStack(alignment: .leading) {
                    if item.status != 3 {
                        Text(String(item.price ?? 0) + " $")
                    }
                }
                .padding()
            }
        }
        .foregroundColor(.white)
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ItemRow(item: staticItem)
            ItemRow(item: staticReservedItem)
            ItemRow(item: staticTakenItem)
        }
    }
}
