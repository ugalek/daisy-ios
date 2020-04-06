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
        List {
            Toggle(isOn: $userData.showReservedOnly) {
                Text("Reserved only")
            }
            ForEach(userData.wishes) { wish in
                if !self.userData.showReservedOnly || wish.isReserved {
                    NavigationLink(
                        destination: WishView(wish: wish)
                            .environmentObject(self.userData)
                    ) {
                        WishRow(wish: wish)
                    }
                }
            }
        }
        .navigationBarTitle(Text("Wishes"))
    }
}

struct WishListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WishListView()
        }
        .environmentObject(UserData())
    }
}
