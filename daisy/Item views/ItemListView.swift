//
//  ItemListView.swift
//  daisy
//
//  Created by Galina on 22/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ItemListView: View {
    @ObservedObject var networkManager = NetworkManager()
    @State var items = [Item]()
    @State var items2D = [[Item]]()
    var listID: String
    
    var body: some View {
        VStack {
//            List {
//                HStack {
//                    Button("Text") {}.padding(8)
//                        .foregroundColor(.white)
//                        .background(Color.red)
//                        .shadow(radius: 4)
//                        .cornerRadius(6)
//                }
//                ForEach(0 ..< items2D.count, id: \.self) { first in
//                    HStack {
//                        ForEach(self.items2D[first], id: \.self) { second in
//                           // NavigationLink(destination: ItemDetail(item: second)) {
//                                ItemPicRow(item: second)
//                            //}
//                        }
//                    }
//                }
//            }
                        List(items) { item in
                NavigationLink(
                    destination: ItemDetail(item: item)
                ) {
                    ItemRow(item: item)
                }
            }
           .navigationBarTitle("List of items")
        }
        .onAppear {
            self.networkManager.genericFetch(urlString: "lists/\(self.listID)/items") { (items: ItemResults) in
                self.items = items.items
                self.items2D = getGridItemData(items: items.items)
            }
        }
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView(
            networkManager: NetworkManager(),
            items: itemData,
            items2D: getGridItemData(items: itemData),
            listID: "")
    }
}
