//
//  ListView.swift
//  daisy
//
//  Created by Galina on 17/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ListView: View {
    @ObservedObject var networkManager = NetworkManager()
    
    @State var showingProfile = false
    var profileButton: some View {
        Button(action: { self.showingProfile.toggle() }) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .accessibility(label: Text("User Profile"))
                .padding()
        }
    }
    
    @State var lists: [Listy]

    var body: some View {
        NavigationView {
            List {
                ForEach(lists) { list in
                    NavigationLink(
                        destination: ItemListView(listID: list.id)
                    ) {
                        ListRow(list: list)
                    }
                }
            }
            .navigationBarTitle("Lists")
            .navigationBarItems(trailing: profileButton)
            .sheet(isPresented: $showingProfile) {
                UserView()
            }
        }
        .onAppear {
            self.networkManager.genericFetch(urlString: "lists/") { (lists: ListResults) in
                self.lists = lists.lists
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(lists: listData)
    }
}
