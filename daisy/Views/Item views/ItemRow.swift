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
            ItemImage(item: item, imageSize: ImageSize.itemRow)
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .foregroundColor(item.status == 3 ? .gray : .dFontColor)
                if item.status != 1 {
                    Text(Item.getRawStatus(status: item.status))
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            if item.status != 3 {
                ItemPrice(item: item)
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
