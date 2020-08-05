//
//  ItemLargeView.swift
//  daisy
//
//  Created by Galina on 20/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ItemLargeView: View {
    var item: Item
    
    var body: some View {
        VStack {
            ImageSquare(item: item, imageSize: ImageSize.itemLargeRow)
            HStack {
                if item.status == 2 {
                    // reserved
                    Image(systemName: "gift.fill")
                        .imageScale(.medium)
                        .foregroundColor(Color.dSecondaryButton)
                } else if item.status == 3 {
                    // taken
                    Image(systemName: "gift.fill")
                        .imageScale(.medium)
                        .foregroundColor(.gray)
                }
                Text(item.title)
                    .font(.footnote)
                    .lineLimit(1)
                    .foregroundColor(.primary)
            }
        }
    }
}
