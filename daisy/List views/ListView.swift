//
//  ListView.swift
//  daisy
//
//  Created by Galina on 17/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ListView: View {    
    @State var showingProfile = false
    var profileButton: some View {
        Button(action: { self.showingProfile.toggle() }) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .accessibility(label: Text("User Profile"))
                .padding()
        }
    }
    
    @State var lists: [UserList]

    var body: some View {
        NavigationView {
            List {
                ForEach(lists) { list in
                    NavigationLink(
                        destination: ItemListView(itemViewModel: ItemsViewModel(list: list), list: list)
                    ) {
                        ListRow(list: list)
                    }
                }
            }
            .navigationBarTitle("Lists", displayMode: .inline)
            .navigationBarItems(trailing: profileButton)
            .sheet(isPresented: $showingProfile) {
                UserView()
            }
        }
        .onAppear {
            DaisyService.genericFetch(endpoint: .lists) { (lists: ListResults) in
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
