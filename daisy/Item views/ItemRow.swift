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
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
                ItemRow(item: itemData[0])
                ItemRow(item: itemData[1])
                ItemRow(item: itemData[2])
            }
            .previewLayout(.fixed(width: 300, height: 70))
        }
}
