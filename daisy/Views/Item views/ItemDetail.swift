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
    var reserveButton: some View {
        Button(action: {
            print("reserve")
        }) {
            HStack{
                Text("Reserve")
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(Color.dSecondaryButton)
                    .cornerRadius(15.0)
            }
        }
    }
    
    var takeButton: some View {
        Button(action: {
            print("taken")
        }) {
            HStack{
                Text("Take it!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(Color.dPrimaryButton)
                    .cornerRadius(15.0)
            }
        }
    }
    
    var seeButton: some View {
        Button(action: {
            print("See")
        }) {
            HStack{
                Text(item.url ?? "")
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(Color.dPrimaryButton)
                    .cornerRadius(15.0)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.dBackground.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    ZStack(alignment: .top) {
                        Image(item.image)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .scaledToFit()
                            .cornerRadius(8)
                        if item.status != 1 {
                            Rectangle()
                                .trim(from: 0, to: 1)
                                .foregroundColor(Color.dBackground)
                                .frame(height: 50, alignment: .center)
                                .opacity(0.2)
                            Text(Item.getRawStatus(status: item.status))
                                .font(.headline)
                                .padding()
                        }
                    }
                    Spacer()
                }
                HStack(spacing: 2) {
                    Text(Item.getPriceString(price: item.price) + " ")
                    Image(systemName: "dollarsign.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                Divider()
                HStack(spacing: 2) {
                    Image(systemName: "link")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                    Link(item.url ?? "/", destination: URL(string: item.url ?? "/")!)
                        .font(.footnote)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .foregroundColor(.dDarkBlueColor)
                ScrollView {
                    Text(item.description)
                        .font(.subheadline)
                }
            }
            .padding()
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text(item.title), displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack(spacing: 2) {
                    Button(action: { print("reserve") }) {
                        Image(systemName: "hourglass")
                            .foregroundColor(.dDarkBlueColor)
                        Text("Reserve")
                    }
                    Spacer()
                    Button(action: { print("Take it") }) {
                        Image(systemName: "cart.badge.plus")
                            .foregroundColor(.dDarkBlueColor)
                        Text("Buy")
                    }
                }
                .foregroundColor(.dDarkBlueColor)
            }
        }
        .modifier(DismissingKeyboardOnSwipe())
    }
}

#if DEBUG
struct ItemDetail_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ItemDetail(item: staticTakenItem)
            }
            .environment(\.colorScheme, .light)
            
            NavigationView {
                ItemDetail(item: staticTakenItem)
            }
            .environment(\.colorScheme, .dark)
        }
    }
}
#endif
