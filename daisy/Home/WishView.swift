//
//  ItemView.swift
//  daisy
//
//  Created by Galina on 16/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct WishView: View {    
    var categories: [String: [Wish]] {
        Dictionary(
            grouping: wishData,
            by: { $0.category.rawValue }
        )
    }
    var taken: [Wish] {
        wishData.filter { $0.isTaken }
    }
    
    @State var showingProfile = false
    
    var profileButton: some View {
        Button(action: { self.showingProfile.toggle() }) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .accessibility(label: Text("User Profile"))
                .padding()
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                if taken.count != 0 {
                    PageView(taken.map { TakenCard(wish: $0) })
                               .aspectRatio(3/2, contentMode: .fit)
                        .listRowInsets(EdgeInsets())
                }
                ForEach(categories.keys.sorted(), id: \.self) { key in
                    CategoryRow(categoryName: key, items: self.categories[key]!)
                }
                .listRowInsets(EdgeInsets())
                
                NavigationLink(destination: WishList()) {
                    Text("See all")
                }
            }
            .navigationBarTitle(Text("My wishes"))
            .navigationBarItems(trailing: profileButton)
            .sheet(isPresented: $showingProfile) {
                UserView()
            }
        }
    }
}

struct TakenWishes: View {
    var wishes: [Wish]
    var body: some View {
        wishes[0].image.resizable()
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        WishView()
    }
}
