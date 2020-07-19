//
//  ItemPrice.swift
//  daisy
//
//  Created by Galina on 19/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ItemPrice: View {
    var item: Item
    var body: some View {
        HStack(spacing: 2) {
            Text(Item.getPriceString(price: item.price) + " ")
            Image(systemName: "dollarsign.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
            
        }
    }
}

struct ItemPrice_Previews: PreviewProvider {
    static var previews: some View {
        ItemPrice(item: staticItem)
            .previewLayout(.sizeThatFits)
    }
}
