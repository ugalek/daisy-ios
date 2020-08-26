//
//  PriceOverlay.swift
//  daisy
//
//  Created by Galina on 27/06/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

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
        ZStack(alignment: .top) {
            if item.status == 2 {
                Rectangle()
                    .trim(from: 0, to: 1)
                    .foregroundColor(Color("Reserved"))
                    .frame(height: 50, alignment: .center)
                    .opacity(0.8)
                    .cornerRadius(8)
            } else if item.status == 3 {
                Rectangle()
                    .trim(from: 0, to: 1)
                    .foregroundColor(Color("Taken"))
                    .frame(height: 50, alignment: .center)
                    .opacity(0.8)
                    .cornerRadius(8)
            }
            Text(Item.getRawStatus(status: item.status))
                .font(.headline)
                .padding()
            ZStack(alignment: .bottomLeading) {
                Rectangle().fill(gradient)
                    .cornerRadius(8)
                if item.status != 3 {
                    HStack {
                        Spacer()
                        ItemPrice(item: item)
                    }
                    .padding()
                }
            }
        }
        .foregroundColor(.white)
    }
}

struct PriceOverlay_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PriceOverlay(item: staticItem)
                .previewLayout(.fixed(width: 150, height: 200))
            PriceOverlay(item: staticReservedItem)
                .previewLayout(.fixed(width: 150, height: 200))
            PriceOverlay(item: staticTakenItem)
                .previewLayout(.fixed(width: 150, height: 200))
        }
        
    }
}

