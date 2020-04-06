//
//  WishView.swift
//  daisy
//
//  Created by Galina on 01/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct WishView: View {
    @EnvironmentObject var userData: UserData
    var wish: Wish

    var wishIndex: Int {
        userData.wishes.firstIndex(where: { $0.id == wish.id })!
    }
    
    var body: some View {
        VStack {
            ZStack {
            TopGradient()
                WishImage(image: wish.image)
                .padding()
              //  .offset(y: 60)
            }
            .edgesIgnoringSafeArea(.top)
            VStack(alignment: .leading) {
                HStack {
                    Text(wish.title)
                        .font(.title)
                        .fontWeight(.thin)
                    Spacer()
                    Button(action: {
                        self.userData.wishes[self.wishIndex]
                            .isReserved.toggle()
                    }) {
                        if self.userData.wishes[self.wishIndex]
                            .isReserved {
                            Image(systemName: "bag.badge.minus.fill")
                                .foregroundColor(.orange)
                        } else {
                            Image(systemName: "bag.badge.plus")
                                .foregroundColor(.gray)
                        }
                    }
                }
                HStack(alignment: .top) {
                    Text(wish.path)
                        .font(.subheadline)
                    Spacer()
                    Text(wish.price)
                        .font(.subheadline)
                }
                Divider()
                HStack {
                    ScrollView {
                        Text(wish.description)
                        .font(.subheadline)
                    }
                }
            }
            .padding()
            Spacer()
        }
        .background(Color("backgroundColor"))
        .navigationBarTitle(Text(wish.title), displayMode: .inline)
    }
}

struct WishView_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        return WishView(wish: wishData[0]).environmentObject(userData)
    }
}
