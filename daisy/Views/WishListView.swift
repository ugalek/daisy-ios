//
//  WishListView.swift
//  daisy
//
//  Created by Galina on 01/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct WishListView: View {
     var body: some View {
        NavigationView {
            List(wishData) { wish in
                NavigationLink(destination: WishView(wish: wish)) {
                    WishRow(wish: wish)
                }
            }
            .navigationBarTitle(Text("Wishes"))
        }
    }
}

struct WishListView_Previews: PreviewProvider {
    static var previews: some View {
        WishListView()
//        ForEach(["iPhone SE", "iPhone XS"], id: \.self) { deviceName in
//            WishListView()
//                .previewDevice(PreviewDevice(rawValue: deviceName))
//        .previewDisplayName(deviceName)
//        }
    }
}
