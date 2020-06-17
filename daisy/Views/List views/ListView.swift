//
//  ListView.swift
//  daisy
//
//  Created by Galina on 17/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var authManager: HttpAuth
    
    @State var showingProfile = false
    @State var loggedOut = false
    
    var profileButton: some View {
        NavigationLink(destination: UserView().environmentObject(self.authManager)) {
           Image(systemName: "person.crop.circle")
            .imageScale(.large)
            .accessibility(label: Text("User Profile"))
        }.buttonStyle(PlainButtonStyle())
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
        }
        .onAppear {
            DaisyService.genericFetch(endpoint: .lists) { (lists: ListResults) in
                self.lists = lists.lists
            }
        }
    }
}
