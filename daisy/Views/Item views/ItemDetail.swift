//
//  ItemDetail.swift
//  daisy
//
//  Created by Galina on 22/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ItemDetail: View {
    var item: Item
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(item.title)
                        .font(.title)
                        .fontWeight(.thin)
                    Spacer()
                    Button(action: {
                        //isReserved.toggle()
                        print("reserve")
                    }) {
                        if item.status == 2 {
                            Image(systemName: "bag.badge.minus.fill")
                                .foregroundColor(.orange)
                        } else {
                            Image(systemName: "bag.badge.plus")
                                .foregroundColor(.gray)
                        }
                    }
                }
                HStack(alignment: .top) {
                    Text("url")
                        .font(.subheadline)
                    Spacer()
                    Text("price")
                        .font(.subheadline)
                }
                Divider()
                HStack {
                    ScrollView {
                        Text(item.description)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            Spacer()
        }
        .background(Color.dBackground)
    }
}

struct ItemDetail_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetail(item: staticItem)
    }
}
