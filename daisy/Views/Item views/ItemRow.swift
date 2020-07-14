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
                if item.imageID != nil {
       // item image
                } else {
                    Image("turtlerock")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                }

                Text(item.title)
                Spacer()
                HStack(spacing: 2) {
                    Text(Item.getPriceString(price: item.price) + " ")
                    Image(systemName: "dollarsign.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                    
                }
            } else if item.status == 2 {
                GiftImage(item: item)
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                    Text(Item.getRawStatus(status: item.status))
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack(spacing: 2) {
                    Text(Item.getPriceString(price: item.price) + " ")
                    Image(systemName: "dollarsign.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                }
            } else {
                GiftImage(item: item)
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .foregroundColor(.gray)
                    Text(Item.getRawStatus(status: item.status))
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
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
