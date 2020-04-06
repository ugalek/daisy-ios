//
//  WishRow.swift
//  daisy
//
//  Created by Galina on 01/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct WishRow: View {
    var wish: Wish
    var body: some View {
        HStack {
            wish.image
                .resizable()
                .frame(width: 50, height: 50)
            Text(wish.title)
            Spacer()
            
            if wish.isReserved {
                Image(systemName: "bag.badge.minus.fill")
                    .imageScale(.medium)
                    .foregroundColor(.orange)
            } else {
                Image(systemName: "bag.badge.plus")
                .imageScale(.medium)
                .foregroundColor(.gray)
            }
        }
    }
}

struct WishRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WishRow(wish: wishData[0])
            WishRow(wish: wishData[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
