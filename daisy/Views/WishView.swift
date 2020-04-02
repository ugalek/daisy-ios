//
//  WishView.swift
//  daisy
//
//  Created by Galina on 01/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct WishView: View {
    var wish: Wish
    var body: some View {
        VStack {
            ZStack {
            TopGradient()
                WishImage(image: wish.image)
                .padding()
              //  .offset(y: 60)
            }
            .edgesIgnoringSafeArea(.top)
            WishDetail(
                title: wish.title,
                path: wish.path,
                price: wish.price,
                description: wish.description)
             Spacer()
        }
        .background(Color("backgroundColor"))
        .navigationBarTitle(Text(wish.title), displayMode: .inline)
    }
}

struct WishView_Previews: PreviewProvider {
    static var previews: some View {
        WishView(wish: wishData[0])
    }
}

struct WishDetail: View {
    let title: String
    let path: String
    let price: String
    let description: String
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title)
                    .fontWeight(.thin)
                Spacer()
                Button(action: {
                    print("Edit tapped!")
                }) {
                    Image(systemName: "pencil")
                        .font(.title)
                        .foregroundColor(Color("buttonColor"))
                }
            }
            HStack(alignment: .top) {
                Text(path)
                    .font(.subheadline)
                Spacer()
                Text(price)
                    .font(.subheadline)
            }
            Divider()
            HStack {
                ScrollView {
                    Text(description)
                    .font(.subheadline)
                }
            }
        }
        .padding()
    }
}
