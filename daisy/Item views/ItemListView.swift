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
    @State var items: [Item] = [Item]()
    var listID: String
    
    var body: some View {
        VStack {
            List(items) { item in
                
                NavigationLink(
                    destination: ItemDetail(item: item)
                ) {
                    ItemRow(item: item)
                }
                
            }
            //.navigationBarTitle("List of items")
        }
        .onAppear {
            self.networkManager.genericFetch(urlString: "lists/\(self.listID)/items") { (items: ItemResults) in
                self.items = items.items
            }
        }
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView(items: [Item](), listID: "01E5Z9PGSW3ZKZ6PHT4FJVYGC3")
    }
}
