//
//  WishListView.swift
//  daisy
//
//  Created by Galina on 01/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct WishListView: View {
    @EnvironmentObject private var userData: UserData
    
     var body: some View {
        NavigationView {
            List {
                Toggle(isOn: $userData.showReservedOnly) {
                    Text("Reserved only")
                }
                
                ForEach(userData.wishes) { wish in
                    if !self.userData.showReservedOnly || wish.isReserved {
                        NavigationLink(
                        destination: WishView(wish: wish)) {
                            WishRow(wish: wish)
                            .environmentObject(self.userData)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Wishes"))
        }
    }
}

struct WishListView_Previews: PreviewProvider {
    static var previews: some View {
        WishListView()
        .environmentObject(UserData())
//        ForEach(["iPhone SE", "iPhone XS"], id: \.self) { deviceName in
//            WishListView()
//                .previewDevice(PreviewDevice(rawValue: deviceName))
//        .previewDisplayName(deviceName)
//        }
    }
}
