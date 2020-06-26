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
                    Image(item.image)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .scaledToFit()
                        .cornerRadius(8)
                    Spacer()
                }
                HStack(spacing: 2) {
                    Image(systemName: "dollarsign.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text(String(item.price ?? 0))
                        .foregroundColor(.black)
                }
                Divider()
                ScrollView {
                    Text(item.description)
                        .font(.subheadline)
                }
                HStack {
                    reserveButton
                    Link("See", destination: URL(string: item.url ?? "/")!)
                    takeButton
                }
            }
            .padding()
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text(item.title), displayMode: .inline)
        .toolbar {
            ToolbarItem {
                Button(action: { print("reserve") }) {
                    Label("reserve", systemImage: "book.circle")
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                Button(action: { print("Take it") }) {
                    Label("Take it", systemImage: "dollarsign.circle")
                }
            }
        }
        .modifier(DismissingKeyboardOnSwipe())
    }
}

#if DEBUG
struct ItemDetail_Previews: PreviewProvider {
    static var previews: some View {
       NavigationView {
            ItemDetail(item: staticItem)
        }
    }
}
#endif
